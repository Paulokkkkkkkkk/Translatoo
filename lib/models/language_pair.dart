import 'language.dart';

/// Par direcionado de idiomas (M1) — chave canônica para tradutores e
/// verificação de prontidão de pacotes (`pt→en` ≠ `en→pt`).
///
/// Tipo de valor imutável: igualdade estrutural para uso como chave de mapa
/// (cache de tradutores ML Kit, estados por par no ViewModel).
final class LanguagePair {
  const LanguagePair({required this.source, required this.target});

  final Language source;
  final Language target;

  /// Par invertido (botão ⇄).
  LanguagePair swapped() => LanguagePair(source: target, target: source);

  @override
  bool operator ==(Object other) =>
      other is LanguagePair && other.source == source && other.target == target;

  @override
  int get hashCode => Object.hash(source, target);

  @override
  String toString() => '${source.mlKitCode}→${target.mlKitCode}';
}
