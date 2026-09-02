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
/// Três breakpoints (PRD §4.1 · F4.2):
/// - **< 600 dp**: coluna única, navegação na gaveta;
/// - **600–1024 dp**: painéis lado a lado na tela Traduzir (ver
///   `TranslateScreen`), navegação ainda na gaveta;
/// - **>= 1024 dp**: `NavigationRail` fixo à esquerda **substituindo a
///   gaveta**, conteúdo centralizado em 720 dp.
///
/// > O critério da issue #38 fala em "substituir a `NavigationBar`". Ela não
/// > existe desde a decisão da §10 (opção A): quem o rail substitui é a
/// > gaveta. O efeito para o usuário é o previsto — em tela larga a navegação
/// > fica permanentemente visível, sem depender do ☰.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // O rail precisa ser decidido no nível do Scaffold, não do corpo: é ele
        // que também remove a gaveta e o ☰ do cabeçalho.
        final wide = constraints.maxWidth >= 1024;

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
          // Em tela larga o rail já mostra os destinos: manter a gaveta seria
          // duas navegações para o mesmo lugar.
          drawer: wide
              ? null
              : _NavigationDrawer(
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
                  child: Row(
                    children: [
                      if (wide)
                        _Rail(
                          selectedIndex: _index,
                          onSelected: (value) => setState(() => _index = value),
                        ),
                      Expanded(
                        child: wide
                            ? Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: _screens[_index],
                                ),
                              )
                            : _screens[_index],
                      ),
                    ],
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
                      onStop: () =>
                          unawaited(context.read<TtsViewModel>().stop()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `NavigationRail` de tela larga (>= 1024 dp). Mesmos três destinos da gaveta,
/// permanentemente visíveis — em desktop não há polegar para alcançar rodapé,
/// e esconder navegação atrás de um ☰ desperdiça a largura que sobra.
class _Rail extends StatelessWidget {
  const _Rail({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.translate_outlined),
          selectedIcon: const Icon(Icons.translate),
          label: Text(t.tabTranslate),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(t.tabHistory),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(t.tabSettings),
        ),
      ],
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
