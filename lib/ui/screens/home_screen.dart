import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../state/connection_view_model.dart';
import '../../state/tts_view_model.dart';
import '../widgets/connection_badge.dart';
import '../widgets/mini_player_tts.dart';
import 'debug_models_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'translate_screen.dart';

/// Shell de navegação (F0.8, redesenhado pela §10 do design system).
///
/// A navegação vive numa **gaveta** (☰ no canto superior esquerdo), como no
/// case — e não mais numa `NavigationBar` de 3 abas. Foi o que destravou a §5.2:
/// com o rodapé livre, a `LanguageBar` de largura total ocupa a zona do polegar
/// sem empilhar 128 dp de crômio fixo (§P5).
///
/// - < 1024 dp: coluna única;
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

  /// F2.7 — a voz pode ter sido instalada no sistema enquanto o app esteve em
  /// segundo plano: ao voltar, o cache de disponibilidade é invalidado.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => context.read<TtsViewModel>().refreshVoices(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // instancia o listener
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

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
      drawer: _NavigationDrawer(
        selectedIndex: _index,
        onSelected: (value) {
          setState(() => _index = value);
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
            // Mini-player (F2.8): só existe durante a reprodução; some sozinho
            // quando a fala termina. Vive na shell porque a voz continua mesmo
            // com o usuário navegando (RN-07).
            Selector<TtsViewModel, (bool, String?)>(
              selector: (_, vm) => (vm.isSpeaking, vm.speakingText),
              builder: (context, data, _) {
                final (speaking, text) = data;
                if (!speaking) return const SizedBox.shrink();
                return MiniPlayerTts(
                  text: text ?? '',
                  onStop: () => unawaited(context.read<TtsViewModel>().stop()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Gaveta de navegação (§10, opção A). Os três destinos da antiga
/// `NavigationBar`, agora acessíveis pelo ☰ — o mesmo lugar do case.
class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      children: [
        // Cabeçalho da gaveta em superfície de marca (§3 plano 1), como o
        // bloco de marca da tela.
        Container(
          height: 120,
          width: double.infinity,
          color: theme.colorScheme.primary,
          padding: const EdgeInsets.all(AppSpacing.lg),
          alignment: Alignment.bottomLeft,
          child: Text(
            t.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        NavigationDrawerDestination(
          icon: const Icon(Icons.translate_outlined),
          selectedIcon: const Icon(Icons.translate),
          label: Text(t.tabTranslate),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(t.tabHistory),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(t.tabSettings),
        ),
      ],
    );
  }
}
