import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../state/connection_view_model.dart';
import '../widgets/connection_badge.dart';
import 'debug_models_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'translate_screen.dart';

/// Shell de navegação responsivo (F0.8):
/// - < 600 dp: coluna única + `NavigationBar`;
/// - 600–1024 dp: preparado p/ cartões lado a lado (layouts entram na F1);
/// - >= 1024 dp: conteúdo centralizado em 720 dp (`NavigationRail` na F4).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _screens = [
    TranslateScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final connection = context.watch<ConnectionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: kDebugMode
            ? GestureDetector(
                onLongPress: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DebugModelsScreen(),
                  ),
                ),
                child: Text(t.appName),
              )
            : Text(t.appName),
        actions: [ConnectionBadge(isOnline: connection.isOnline)],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final screen = _screens[_index];
            if (width >= 1024) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: screen,
                ),
              );
            }
            return screen;
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.translate_outlined),
            selectedIcon: const Icon(Icons.translate),
            label: t.tabTranslate,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: t.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: t.tabSettings,
          ),
        ],
      ),
    );
  }
}
