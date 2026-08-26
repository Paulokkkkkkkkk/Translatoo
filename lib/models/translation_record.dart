import 'language.dart';

/// Registro imutável do histórico/favoritos (M4).
///
/// Round-trip JSON garantido por teste; leitura tolera campos ausentes
/// (aplica defaults). JSON corrompido no nível da coleção é tratado pelo
/// StorageService, que reinicia a lista sem propagar exceção (RN-03).
class TranslationRecord {
  const TranslationRecord({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.isFavorite = false,
  });

  final String id;
  final String sourceText;
  final String translatedText;
  final Language sourceLang;
  final Language targetLang;

  /// Momento da tradução, sempre em UTC para portabilidade.
  final DateTime timestamp;
  final bool isFavorite;

  TranslationRecord copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    Language? sourceLang,
    Language? targetLang,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return TranslationRecord(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'sourceText': sourceText,
    'translatedText': translatedText,
    'sourceLang': sourceLang.jsonCode,
    'targetLang': targetLang.jsonCode,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'isFavorite': isFavorite,
  };

  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      id: json['id'] as String? ?? '',
      sourceText: json['sourceText'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      sourceLang:
          Language.tryFromCode(json['sourceLang'] as String?) ?? Language.pt,
      targetLang:
          Language.tryFromCode(json['targetLang'] as String?) ?? Language.en,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TranslationRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TranslationRecord($id, ${sourceLang.jsonCode}->${targetLang.jsonCode})';
}
