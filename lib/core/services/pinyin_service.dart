import 'package:pinyin/pinyin.dart';

import '../../models/language.dart';

/// Romanização de texto chinês (RF-M1-11 · design system §5.13).
///
/// Fica atrás de uma interface pela mesma razão dos outros motores: a `ui/` e
/// os ViewModels não conhecem o pacote, e os testes não dependem do dicionário
/// real para verificar QUANDO a linha aparece.
abstract interface class PinyinEngine {
  /// Romaniza [text]. Caracteres não-chineses passam inalterados.
  String romanize(String text);
}

/// Implementação sobre `package:pinyin` — Dart puro, dicionário embutido,
/// zero rede. A conversão é por EXPRESSÃO, não por caractere: é o que faz
/// 长大 sair como `zhǎng dà` e não `cháng dà`.
final class PackagePinyinEngine implements PinyinEngine {
  const PackagePinyinEngine();

  @override
  String romanize(String text) => PinyinHelper.getPinyin(
    text,
    separator: ' ',
    format: PinyinFormat.WITH_TONE_MARK,
  );
}

/// Decide se um texto merece linha de pinyin, e a produz.
///
/// A regra de "merece" não é o idioma sozinho: um resultado em `zh` pode ser
/// só um número ou uma sigla, e romanizar isso devolveria o próprio texto —
/// uma linha duplicada que não ensina nada.
final class PinyinService {
  const PinyinService({this.engine = const PackagePinyinEngine()});

  final PinyinEngine engine;

  /// Faixas Han unificadas — o suficiente para "tem caractere chinês aqui?".
  /// Extensões raras (B–F) ficam de fora de propósito: o dicionário do pacote
  /// não as cobre, então incluí-las só produziria linha repetida.
  static final RegExp _han = RegExp(r'[一-鿿㐀-䶿]');

  /// Linha de pinyin para [text] no [language], ou `null` quando não cabe.
  ///
  /// Devolve `null` — e não string vazia — para que a UI possa OMITIR a linha:
  /// espaço reservado para nada é ruído (§5.13).
  ///
  /// Falha do dicionário não vira erro: o hanzi continua na tela sem o apoio.
  /// Transformar uma tradução correta em erro por causa de um auxílio de
  /// leitura seria trocar uma coisa que funciona por outra que não.
  String? romanizeFor(Language language, String text) {
    if (language != Language.zh) return null;
    if (!_han.hasMatch(text)) return null;
    try {
      final result = _tidy(engine.romanize(text));
      if (result.isEmpty || result == text.trim()) return null;
      return result;
    } on Object catch (_) {
      return null;
    }
  }

  /// Espaço ANTES de pontuação é artefato do separador: o pacote trata `。` e
  /// `，` como caracteres a separar, e sai `yù shì 。`. Ninguém escreve assim
  /// em nenhuma das duas escritas.
  static final RegExp _spaceBeforePunctuation = RegExp(
    r'\s+([。，、；：？！）】」』,.;:?!\)\]])',
  );

  /// Espaço DEPOIS de pontuação de largura plena. Esses glifos já ocupam um
  /// em inteiro, com folga embutida à direita; somar um espaço abre um vão
  /// visível. A pontuação ASCII não entra aqui — ali o espaço é normal.
  static final RegExp _spaceAfterWidePunctuation = RegExp(r'([。，、；：？！）】」』]) +');

  /// Sobras do separador: dois espaços seguidos aparecem quando o texto
  /// original já tinha espaço entre um bloco chinês e outro.
  static final RegExp _doubleSpace = RegExp(r' {2,}');

  String _tidy(String raw) => raw
      // `replaceAll` NÃO interpreta `$1` — só a versão `Mapped` dá acesso ao
      // grupo capturado.
      .replaceAllMapped(_spaceBeforePunctuation, (m) => m.group(1)!)
      .replaceAllMapped(_spaceAfterWidePunctuation, (m) => m.group(1)!)
      .replaceAll(_doubleSpace, ' ')
      .trim();
}
