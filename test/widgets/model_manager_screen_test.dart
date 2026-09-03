import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/ui/screens/model_manager_screen.dart';

/// API com downloads RETIDOS até [complete] (mesmo padrão da tela Traduzir).
class _GateApi implements ModelManagerApi {
  _GateApi({Iterable<Language> installed = const []}) {
    this.installed.addAll(installed);
  }

  final Set<Language> installed = <Language>{};
  final Map<Language, Completer<void>> pending = <Language, Completer<void>>{};

  @override
  Future<bool> isModelDownloaded(Language language) async =>
      installed.contains(language);

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) {
    final completer = Completer<void>();
    pending[language] = completer;
    return completer.future;
  }

  void complete(Language language) {
    final completer = pending.remove(language);
    if (completer == null) return;
    installed.add(language);
    completer.complete();
  }

  @override
  Future<void> deleteModel(Language language) async {
    installed.remove(language);
  }
}

Future<void> _pump(WidgetTester tester, ModelManagerService manager) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await manager.refreshAll();
  await tester.pumpWidget(
    Provider<ModelManagerService>.value(
      value: manager,
      child: const MaterialApp(home: ModelManagerScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('mostra os 3 idiomas com estado real (F3.4)', (tester) async {
    final manager = ModelManagerService(
      api: _GateApi(installed: Language.values),
    );
    await _pump(tester, manager);

    // Nota (padrão dos testes): o MaterialApp usa o locale do HOST (en-US).
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
    expect(find.textContaining('Ready'), findsNWidgets(3));
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(3));

    manager.dispose();
  });

  testWidgets('exclusão pede confirmação e reflete o estado (F3.4)', (
    tester,
  ) async {
    final api = _GateApi(installed: Language.values);
    final manager = ModelManagerService(api: api);
    await _pump(tester, manager);

    // Excluir Português: diálogo de confirmação.
    await tester.tap(find.byTooltip('Delete').first);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Delete the Português package?'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(api.installed, isNot(contains(Language.pt)));
    expect(find.textContaining('Not installed'), findsOneWidget);
    expect(find.textContaining('Ready'), findsNWidgets(2));

    manager.dispose();
  });

  testWidgets('cancelar a exclusão mantém o pacote (F3.4)', (tester) async {
    final manager = ModelManagerService(
      api: _GateApi(installed: Language.values),
    );
    await _pump(tester, manager);

    await tester.tap(find.byTooltip('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ready'), findsNWidgets(3));

    manager.dispose();
  });
}
