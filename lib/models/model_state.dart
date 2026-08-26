/// Estado de um pacote de idiomas na máquina local (F1.3).
///
/// Hierarquia SELADA: a UI faz switch exaustivo sem `default` — novos estados
/// quebram compilação, nunca silenciosamente a UI.
sealed class ModelState {
  const ModelState();
}

/// Pacote ausente no aparelho — download disponível.
final class ModelNotDownloaded extends ModelState {
  const ModelNotDownloaded();

  @override
  bool operator ==(Object other) => other is ModelNotDownloaded;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Download em curso com progresso estimado (0–100).
///
/// O plugin `google_mlkit_translation` não expõe progresso nativo; o valor é
/// uma estimativa determinística produzida pelo [ModelManagerService] enquanto
/// sondagem confirma a conclusão real (ver nota técnica lá).
final class ModelDownloading extends ModelState {
  const ModelDownloading(this.progressPercent)
    : assert(progressPercent >= 0 && progressPercent <= 100);

  final int progressPercent;

  @override
  bool operator ==(Object other) =>
      other is ModelDownloading && other.progressPercent == progressPercent;

  @override
  int get hashCode => Object.hash(runtimeType, progressPercent);
}

/// Pacote instalado — tradução neste idioma funciona 100% offline.
final class ModelReady extends ModelState {
  const ModelReady();

  @override
  bool operator ==(Object other) => other is ModelReady;

  @override
  int get hashCode => runtimeType.hashCode;
}
