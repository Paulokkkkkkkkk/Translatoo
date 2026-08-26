import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/translation_record.dart';

TranslationRecord _record() => TranslationRecord(
  id: 'rec-1',
  sourceText: 'Bom dia',
  translatedText: '早上好',
  sourceLang: Language.pt,
  targetLang: Language.zh,
  timestamp: DateTime.utc(2026, 8, 26, 12),
);

void main() {
  group('TranslationRecord — round-trip JSON (F0.6)', () {
    test('toJson → fromJson preserva todos os campos', () {
      final original = _record();
      final restored = TranslationRecord.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(restored.id, original.id);
      expect(restored.sourceText, original.sourceText);
      expect(restored.translatedText, original.translatedText);
      expect(restored.sourceLang, Language.pt);
      expect(restored.targetLang, Language.zh);
      expect(restored.timestamp, original.timestamp); // UTC preservado
      expect(restored.isFavorite, isFalse);
      expect(restored, original); // igualdade por id
    });

    test('isFavorite sobrevive ao round-trip', () {
      final favorited = _record().copyWith(isFavorite: true);
      final restored = TranslationRecord.fromJson(favorited.toJson());
      expect(restored.isFavorite, isTrue);
    });

    test('fromJson tolera campos ausentes (defaults)', () {
      final record = TranslationRecord.fromJson(const <String, dynamic>{});
      expect(record.id, '');
      expect(record.sourceLang, Language.pt);
      expect(record.targetLang, Language.en);
      expect(record.isFavorite, isFalse);
    });

    test('copyWith substitui apenas os campos informados', () {
      final updated = _record().copyWith(translatedText: 'Good morning');
      expect(updated.translatedText, 'Good morning');
      expect(updated.sourceText, 'Bom dia');
      expect(updated.id, 'rec-1');
      expect(updated.timestamp, _record().timestamp);
    });
  });
}
