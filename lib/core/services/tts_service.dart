import 'dart:async';

import '../../models/language.dart';
import 'app_exception.dart';

/// Evento de ciclo de vida da síntese, do [TtsService] para quem observa
/// (o `TtsViewModel` na F2.7 e a UI na F2.8).
enum TtsEventKind { started, completed, cancelled }

/// Um evento de ciclo de vida da voz. Falha de motor NÃO vira `TtsEvent`:
/// desce como *erro do stream* (mesmo contrato do STT), carregando
/// [AppException] — nunca um evento limpo.
class TtsEvent {
  const TtsEvent(this.kind);

  final TtsEventKind kind;

  @override
  bool operator ==(Object other) => other is TtsEvent && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;

  @override
  String toString() => 'TtsEvent(${kind.name})';
}

/// Motor de TTS nativo atrás de uma interface — mesmo movimento do SttEngine:
/// a produção embrulha o plugin `flutter_tts` (motor do SO, RF-M3-01) e os
/// testes injetam um fake.
///
/// CONTRATO DE SESSÃO: cada [speak] (ou [stop]) abre uma nova sessão interna e
/// invalida a anterior — callbacks atrasados da emissão velha são descartados
/// PELO MOTOR. O [events] só entrega eventos da sessão corrente, nesta ordem
/// possível: `started` (fala começou), depois exatamente um entre
/// `completed`/`cancelled`. [stop] sempre emite `cancelled` ao interromper uma
/// emissão ativa.
abstract interface class TtsEngine {
  /// A voz do locale [ttsCode] existe no SO?
  Future<bool> isLanguageAvailable(String ttsCode);

  /// Prepara o motor para falar: idioma, velocidade e tom. Chamado antes de
  /// cada [speak] — configurar por chamada garante que um parâmetro novo dos
  /// sliders vale já na reprodução seguinte.
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  });

  /// Fala [text]. Interrompe qualquer emissão anterior (fila única no motor).
  /// Um `started` correspondente chega no [events]; se o motor falhar ao
  /// iniciar, o erro chega como erro do [events].
  Future<void> speak(String text);

  /// Interrompe a síntese em curso e emite `cancelled`. Sem emissão ativa é
  /// no-op silencioso.
  Future<void> stop();

  /// Ciclo de vida da sessão corrente + erros de motor.
  Stream<TtsEvent> get events;

  Future<void> dispose();
}

/// Leitura em voz alta atrás de uma interface independente de fornecedor
/// (F2.6 / PRD §3.3, M3).
///
/// REGRAS DO PRD implementadas aqui:
/// - **RF-M3-01/03** — fala exclusivamente com o motor nativo do SO; idioma =
///   idioma de DESTINO da tradução.
/// - **Fila única (AC-M3-3)** — o motor interrompe a emissão anterior a cada
///   novo [speak]; o [events] nunca carrega eventos de sessões velhas, então o
///   serviço não pode emitir duas vozes nem "acabar" uma fala que já morreu.
/// - **Voz ausente** — checagem prévia com cache (`isLanguageAvailable` do SO);
///   ausente vira `AppException(ttsVoiceMissing)` com ação `openSettings`. O
///   deep-link direto para as configurações de TTS do SO é pendência registrada
///   (nenhum plugin da lista fechada o expõe) — a mensagem instrui o caminho.
/// - **RN-03** — nenhuma exceção crua atravessa: falha de motor vira erro do
///   [events] (e, na prática, o desfecho mais comum é voz ausente — risco R3).
class TtsService {
  TtsService({required TtsEngine engine}) : _engine = engine {
    _engineSub = engine.events.listen(
      _onEngineEvent,
      onError: (Object error, StackTrace stack) => _onEngineError(error, stack),
    );
  }

  final TtsEngine _engine;

  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();

  StreamSubscription<TtsEvent>? _engineSub;

  /// Ciclo de vida da síntese corrente; erros chegam via `onError` como
  /// [AppException].
  Stream<TtsEvent> get events => _events.stream;

  /// Parâmetros de voz vigentes (modelo normalizado do `AppSettings`). A
  /// persistência é da F3 (Ajustes); aqui eles valem para a próxima [speak].
  double _rate = 0.5; // normalizado 0..1; 0,5 ≈ velocidade normal no SO.
  double _pitch = 1.0; // 0,5–2,0; 1,0 = normal (escala nativa do plugin).

  double get rate => _rate;
  double get pitch => _pitch;

  /// Cache de disponibilidade de voz por idioma — `null` = ainda não sabido.
  final Map<Language, bool> _voiceCache = <Language, bool>{};

  bool _speaking = false;

  /// Há uma síntese em curso?
  bool get isSpeaking => _speaking;

  /// Atualiza a velocidade (normalizada 0..1) para as próximas reproduções.
  void setRate(double value) => _rate = value.clamp(0.0, 1.0);

  /// Atualiza o tom (0,5–2,0; 1,0 normal) para as próximas reproduções.
  void setPitch(double value) => _pitch = value.clamp(0.5, 2.0);

  /// Voz de [language] disponível? Consulta o SO na primeira vez e guarda.
  Future<bool> ensureVoice(Language language) async {
    final cached = _voiceCache[language];
    if (cached != null) return cached;
    try {
      final available = await _engine.isLanguageAvailable(language.ttsCode);
      _voiceCache[language] = available;
      return available;
    } catch (e, st) {
      // Sem motor de TTS o `isLanguageAvailable` também falha: o desfecho para
      // o usuário é o mesmo — instalar voz no sistema.
      throw AppException(
        ErrorCode.ttsVoiceMissing,
        suggestedAction: SuggestedAction.openSettings,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Invalida o cache (abertura do app / volta de segundo plano — F2.7): a voz
  /// pode ter sido instalada enquanto o app esteve fora.
  void refreshVoices() => _voiceCache.clear();

  /// Fala [text] no idioma [language] — sempre o de DESTINO da tradução.
  ///
  /// Voz ausente lança `AppException(ttsVoiceMissing)` ANTES de qualquer
  /// chamada ao motor.
  ///
  /// FILA ÚNICA (AC-M3-3): interrompe explicitamente a fala em curso antes de
  /// começar a próxima. Delegar isso ao motor não funciona nos dois SOs — o
  /// Android usa `QUEUE_FLUSH` e substitui, mas o `AVSpeechSynthesizer` do iOS
  /// **enfileira**, e duas traduções seguidas sairiam uma depois da outra em
  /// vez de a segunda cancelar a primeira.
  Future<void> speak({required Language language, required String text}) async {
    if (text.trim().isEmpty) return;
    await stop();
    if (!await ensureVoice(language)) {
      // Cache diz que a voz não existe: erro ANTES de qualquer chamada ao
      // motor, com a ação que a tabela §4.8 prevê para o caso.
      throw const AppException(
        ErrorCode.ttsVoiceMissing,
        suggestedAction: SuggestedAction.openSettings,
      );
    }

    _speaking = true;
    try {
      await _engine.configure(
        languageCode: language.ttsCode,
        rate: _rate,
        pitch: _pitch,
      );
      await _engine.speak(text);
    } catch (e, st) {
      _speaking = false;
      throw AppException(
        ErrorCode.ttsVoiceMissing,
        suggestedAction: SuggestedAction.openSettings,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Interrompe a síntese em curso (o motor emite `cancelled`). Sem emissão =
  /// no-op.
  Future<void> stop() async {
    if (!_speaking) return;
    _speaking = false;
    await _engine.stop();
  }

  /// Largou a sessão (dispose do ViewModel / app saindo). A emissão em curso
  /// é interrompida; quem estava ouvindo já morreu junto.
  Future<void> dispose() async {
    _speaking = false;
    await _engine.stop();
    await _engine.dispose();
    await _engineSub?.cancel();
    await _events.close();
  }

  // ── Interno ──────────────────────────────────────────────────────────────

  /// Repassa eventos da sessão corrente. [started] mantém a fala em curso;
  /// [completed]/[cancelled] encerram e são repassados ao observador.
  void _onEngineEvent(TtsEvent event) {
    switch (event.kind) {
      case TtsEventKind.started:
        if (!_speaking) return; // órfão: nada ativo em curso
        _events.add(event);
      case TtsEventKind.completed || TtsEventKind.cancelled:
        if (!_speaking) return; // órfão (ex.: stop já tratado pelo serviço)
        _speaking = false;
        _events.add(event);
    }
  }

  void _onEngineError(Object error, StackTrace stackTrace) {
    if (!_speaking) return;
    _speaking = false;
    _events.addError(
      AppException(
        ErrorCode.ttsVoiceMissing,
        suggestedAction: SuggestedAction.openSettings,
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
