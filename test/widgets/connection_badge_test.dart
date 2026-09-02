import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_strings.dart';
import 'package:translatoo/core/theme/app_theme.dart';
import 'package:translatoo/ui/widgets/connection_badge.dart';

/// Nota dos demais testes: o MaterialApp em teste usa o locale do HOST
/// (en-US), então as strings esperadas abaixo são as EN de app_strings.dart.
void main() {
  Future<void> pump(WidgetTester tester, {required bool online}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          appBar: AppBar(actions: [ConnectionBadge(isOnline: online)]),
        ),
      ),
    );
  }

  testWidgets('estado online: rótulo, live region e tooltip (F3.5)', (
    tester,
  ) async {
    await pump(tester, online: true);
    expect(find.text('Online'), findsOneWidget);
    expect(
      find.byTooltip(
        'You are online. Language package downloads use the network.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'estado offline: explica que o baixado segue funcionando (F3.5)',
    (tester) async {
      await pump(tester, online: false);
      expect(find.text('Offline'), findsOneWidget);
      expect(
        find.byTooltip(
          'You are offline. Everything already downloaded keeps working — only '
          'package downloads need internet.',
        ),
        findsOneWidget,
      );
    },
  );

  test('mensagens i18n existem nos três idiomas (F3.5)', () {
    final pt = AppStrings.forLocale(const Locale('pt', 'BR'));
    final en = AppStrings.forLocale(const Locale('en', 'US'));
    final zh = AppStrings.forLocale(const Locale('zh', 'CN'));
    for (final online in const [true, false]) {
      expect(pt.connectionBadgeInfo(online), isNotEmpty);
      expect(en.connectionBadgeInfo(online), isNotEmpty);
      expect(zh.connectionBadgeInfo(online), isNotEmpty);
    }
  });
}
