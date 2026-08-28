# Graph Report - .  (2026-08-28)

## Corpus Check
- 48 files · ~16,317 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 680 nodes · 899 edges · 43 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- connectivityplatform Community
- appexception_get Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- appsettings_get Community
- core_services_app_exception_dart Community
- bool_get Community
- completer Community
- lib_models_app_settings Community
- dart_ui Community
- package_translatoo_state_translator_view_model_dart Community
- core_services_mlkit_translation_backend_dart Community
- datetime Community
- changenotifier Community
- dart_convert Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- package_translatoo_core_services_translation_backend_dart Community
- animationcontroller Community
- constants_app_constants_dart Community
- package_translatoo_core_services_app_exception_dart Community
- core_constants_app_strings_dart Community
- exception Community
- core_services_model_manager_service_dart Community
- lib_core_services_mlkit_translation_backend Community
- color Community
- constants_app_colors_dart Community
- int_get Community
- lib_core_constants_app_spacing Community
- package_flutter_test_flutter_test_dart Community
- lib_models_language Community
- app_exception_dart Community
- lib_core_services_translation_backend Community
- lib_models_model_state Community
- lib_ui_widgets_language_pill Community
- icondata Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
- lib_main_translatooapp Community
- lib_ui_screens_home_screen_homescreen Community
- core_constants_app_spacing_dart Community
- lib_core_constants_app_strings_appstrings Community
- package_translatoo_core_constants_app_constants_dart Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 12 edges
2. `ModelManagerService` - 11 edges
3. `TranslationBackend` - 8 edges
4. `Language` - 8 edges
5. `AppException` - 6 edges
6. `ModelManagerApi` - 6 edges
7. `ModelState` - 6 edges
8. `ConnectionViewModel` - 6 edges
9. `_TranslateScreenState` - 5 edges
10. `AppStrings` - 4 edges

## Surprising Connections (you probably didn't know these)
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/services/model_manager_service_test.dart → lib/core/services/model_manager_service.dart
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/translator_view_model_test.dart → lib/core/services/model_manager_service.dart
- `_StubApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/widgets/home_shell_test.dart → lib/core/services/model_manager_service.dart
- `_GateApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/widgets/translate_screen_test.dart → lib/core/services/model_manager_service.dart
- `FakeEchoBackend` --implements--> `TranslationBackend`  [EXTRACTED]
  test/services/translation_service_test.dart → lib/core/services/translation_backend.dart

## Import Cycles
- None detected.

## Communities (43 total, 0 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (58): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+50 more)

### Community 1 - "connectivityplatform Community"
Cohesion: 0.05
Nodes (38): ConnectivityPlatform, actions, build, child, expandChild, footer, leading, List (+30 more)

### Community 2 - "appexception_get Community"
Cohesion: 0.05
Nodes (37): AppException? get, Language get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, clearSource, confirmDownloadAnyway, _debounce (+29 more)

### Community 3 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (31): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, history, historyLimit (+23 more)

### Community 4 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (31): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+23 more)

### Community 5 - "appsettings_get Community"
Cohesion: 0.07
Nodes (27): AppSettings get, Duration, Future, dispose, _disposed, _favorites, flush, _flushing (+19 more)

### Community 6 - "core_services_app_exception_dart Community"
Cohesion: 0.11
Nodes (21): ../../core/services/app_exception.dart, TranslatorViewModel, _controller, _copyTranslation, createState, _DestinationSection, didChangeDependencies, dispose (+13 more)

### Community 7 - "bool_get Community"
Cohesion: 0.10
Nodes (19): bool get, Connectivity, ../core/services/connectivity_service.dart, _apply, _connectivity, ConnectivityService, dispose, isOnline (+11 more)

### Community 8 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 9 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 10 - "dart_ui Community"
Cohesion: 0.11
Nodes (18): dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary, colorOnPrimaryContainer (+10 more)

### Community 11 - "package_translatoo_state_translator_view_model_dart Community"
Cohesion: 0.11
Nodes (18): package:translatoo/state/translator_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, complete, deleteModel, dispose, downloadModel, id (+10 more)

### Community 12 - "core_services_mlkit_translation_backend_dart Community"
Cohesion: 0.11
Nodes (17): core/services/mlkit_translation_backend.dart, core/services/storage_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart, core/theme/app_theme.dart, StorageService, build, connectivity (+9 more)

### Community 13 - "datetime Community"
Cohesion: 0.12
Nodes (15): DateTime, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+7 more)

### Community 14 - "changenotifier Community"
Cohesion: 0.14
Nodes (14): ChangeNotifier, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, _index, _screens (+6 more)

### Community 15 - "dart_convert Community"
Cohesion: 0.14
Nodes (13): dart:convert, Map, package:fake_async/fake_async.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/translation_record.dart, main, _record (+5 more)

### Community 16 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 17 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 18 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.13
Nodes (14): package:translatoo/core/services/translation_backend.dart, package:translatoo/core/services/translation_service.dart, beginCapture, dispose, id, isModelDownloaded, isReady, main (+6 more)

### Community 19 - "animationcontroller Community"
Cohesion: 0.15
Nodes (13): AnimationController, BorderRadius?, borderRadius, build, _controller, createState, dispose, height (+5 more)

### Community 20 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 21 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 22 - "core_constants_app_strings_dart Community"
Cohesion: 0.20
Nodes (9): ../../core/constants/app_strings.dart, build, HistoryScreen, build, SettingsScreen, package:flutter/material.dart, package:translatoo/core/constants/app_strings.dart, main (+1 more)

### Community 23 - "exception Community"
Cohesion: 0.17
Nodes (11): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+3 more)

### Community 24 - "core_services_model_manager_service_dart Community"
Cohesion: 0.24
Nodes (10): ../../core/services/model_manager_service.dart, dart:async, ModelManagerService, build, DebugModelsScreen, language, _ModelTile, state (+2 more)

### Community 25 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.18
Nodes (10): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+2 more)

### Community 26 - "color Community"
Cohesion: 0.20
Nodes (9): Color, ../../core/constants/app_constants.dart, build, language, onCancel, onDownload, state, ../../models/model_state.dart (+1 more)

### Community 27 - "constants_app_colors_dart Community"
Cohesion: 0.20
Nodes (9): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppTheme, _build, dark, light, _Tokens (+1 more)

### Community 28 - "int_get Community"
Cohesion: 0.20
Nodes (9): int get, language.dart, hashCode, LanguagePair, operator, source, swapped, target (+1 more)

### Community 29 - "lib_core_constants_app_spacing Community"
Cohesion: 0.20
Nodes (9): AppSpacing, lg, md, minTouchTarget, radius, sm, xl, xs (+1 more)

### Community 30 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.24
Nodes (7): package:flutter_test/flutter_test.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/language_pair.dart, main, main, main

### Community 31 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, Language, mlKitCode, tryFromCode, ttsCode, voskCode

### Community 32 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, translation_backend.dart

### Community 33 - "lib_core_services_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart, String get

### Community 34 - "lib_models_model_state Community"
Cohesion: 0.36
Nodes (7): hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 35 - "lib_ui_widgets_language_pill Community"
Cohesion: 0.25
Nodes (7): build, language, onSelected, semanticLabel, ../../models/language.dart, String?, ValueChanged

### Community 36 - "icondata Community"
Cohesion: 0.29
Nodes (6): IconData, build, icon, message, PlaceholderPanel, title

### Community 37 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.29
Nodes (7): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _StubBackend, _EchoBackend

### Community 38 - "lib_main_translatooapp Community"
Cohesion: 0.33
Nodes (6): TranslatooApp, _OriginFooter, DownloadProgressCard, LanguagePill, TranslationCard, StatelessWidget

### Community 39 - "lib_ui_screens_home_screen_homescreen Community"
Cohesion: 0.40
Nodes (6): HomeScreen, _HomeScreenState, TranslateScreen, _TranslateScreenState, State, StatefulWidget

### Community 40 - "core_constants_app_spacing_dart Community"
Cohesion: 0.40
Nodes (4): ../../core/constants/app_spacing.dart, build, ConnectionBadge, isOnline

### Community 41 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 42 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **445 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+440 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `lib_models_language Community` to `appexception_get Community`, `lib_ui_widgets_language_pill Community`, `lib_models_app_settings Community`, `datetime Community`, `core_services_model_manager_service_dart Community`, `color Community`, `int_get Community`?**
  _High betweenness centrality (0.118) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `appexception_get Community`, `package_translatoo_core_services_translation_backend_dart Community`, `package_translatoo_core_services_app_exception_dart Community`, `core_services_app_exception_dart Community`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Why does `ModelManagerService` connect `core_services_model_manager_service_dart Community` to `appexception_get Community`, `lib_core_services_model_manager_service Community`, `core_services_app_exception_dart Community`, `lib_ui_screens_home_screen_homescreen Community`, `completer Community`, `core_services_mlkit_translation_backend_dart Community`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _445 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.03389830508474576 - nodes in this community are weakly interconnected._
- **Should `connectivityplatform Community` be split into smaller, more focused modules?**
  _Cohesion score 0.054878048780487805 - nodes in this community are weakly interconnected._
- **Should `appexception_get Community` be split into smaller, more focused modules?**
  _Cohesion score 0.05263157894736842 - nodes in this community are weakly interconnected._