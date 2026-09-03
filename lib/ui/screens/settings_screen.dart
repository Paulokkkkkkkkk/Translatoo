import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/app_settings.dart';
import '../../models/language.dart';
import '../../state/library_view_model.dart';
import '../../state/settings_view_model.dart';
import 'model_manager_screen.dart';

/// Tela Ajustes (F3.3 · PRD §3.5).
///
/// Todas as preferências num lugar só, persistidas pelo [SettingsViewModel].
/// Os sliders de voz vieram do painel de debug da F2.8, como a issue previa.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Versão exibida no rodapé. Vem do pubspec via `--dart-define` no build de
  /// release; em debug o default basta.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.1.0',
  );

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) => ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _SectionTitle(t.settingsLanguagePair),
          _LanguageTile(
            label: t.settingsSourceLanguage,
            value: settings.sourceLanguage,
            onSelected: settings.setSourceLanguage,
          ),
          _LanguageTile(
            label: t.settingsTargetLanguage,
            value: settings.targetLanguage,
            onSelected: settings.setTargetLanguage,
          ),

          const Divider(height: AppSpacing.lg),
          _SectionTitle(t.actionListen),
          SwitchListTile(
            title: Text(t.settingsAutoplay),
            value: settings.autoPlay,
            onChanged: settings.setAutoPlay,
          ),
          _SliderTile(
            label: t.settingsVoiceRate,
            value: settings.ttsRate,
            onChanged: settings.setTtsRate,
          ),
          _SliderTile(
            label: t.settingsVoicePitch,
            value: settings.ttsPitch,
            min: 0.5,
            max: 2,
            onChanged: settings.setTtsPitch,
          ),

          const Divider(height: AppSpacing.lg),
          _SectionTitle(t.settingsTheme),
          _ThemeSelector(
            value: settings.themeMode,
            onChanged: settings.setThemeMode,
          ),

          const Divider(height: AppSpacing.lg),
          SwitchListTile(
            title: Text(t.settingsWifiOnly),
            value: settings.wifiOnly,
            onChanged: settings.setWifiOnly,
          ),
          ListTile(
            title: Text(t.settingsManageModels),
            trailing: const Icon(Icons.chevron_right),
            // F3.4: o Gerenciador de Modelos de produto substitui a tela de
            // debug da F1.3 neste destino.
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ModelManagerScreen(),
              ),
            ),
          ),
          ListTile(
            title: Text(t.settingsClearHistory),
            // Ação destrutiva: cor de erro no rótulo, confirmação no toque.
            textColor: theme.colorScheme.error,
            onTap: () => _confirmClearHistory(context),
          ),

          const Divider(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A declaração de privacidade tem de bater EXATAMENTE com a
                // política publicada (RF-REL-03): divergência entre as duas é
                // motivo de rejeição na loja.
                Text(
                  t.settingsPrivacy,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${t.settingsAppVersion} $appVersion'
                  '${kDebugMode ? ' (debug)' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final t = AppStrings.of(context);
    final library = context.read<LibraryViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.confirmClearHistoryTitle),
        content: Text(t.confirmClearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionClearAll),
          ),
        ],
      ),
    );
    if (confirmed ?? false) library.clearHistory();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.xs,
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.value,
    required this.onSelected,
  });

  final String label;
  final Language value;
  final ValueChanged<Language> onSelected;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    trailing: DropdownButton<Language>(
      value: value,
      underline: const SizedBox.shrink(),
      onChanged: (choice) {
        if (choice != null) onSelected(choice);
      },
      items: [
        for (final language in Language.values)
          DropdownMenuItem<Language>(
            value: language,
            child: Text(language.displayName),
          ),
      ],
    ),
  );
}

/// Slider com o valor numérico ao lado do rótulo — a issue pede explicitamente
/// o número: "rápido" e "lento" não dizem onde o usuário está na escala.
class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    ),
  );
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.value, required this.onChanged});

  final SettingsThemeMode value;
  final ValueChanged<SettingsThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final labels = <SettingsThemeMode, String>{
      SettingsThemeMode.system: t.settingsThemeSystem,
      SettingsThemeMode.light: t.settingsThemeLight,
      SettingsThemeMode.dark: t.settingsThemeDark,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SegmentedButton<SettingsThemeMode>(
        segments: [
          for (final entry in labels.entries)
            ButtonSegment<SettingsThemeMode>(
              value: entry.key,
              label: Text(entry.value),
            ),
        ],
        selected: <SettingsThemeMode>{value},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
