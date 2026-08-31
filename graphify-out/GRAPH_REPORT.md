# Graph Report - .  (2026-08-31)

## Corpus Check
- 50 files · ~17,108 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 693 nodes · 917 edges · 34 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- core_services_app_exception_dart Community
- color Community
- animationcontroller Community
- appexception_get Community
- connectivityplatform Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- appsettings_get Community
- dart_math Community
- bool_get Community
- completer Community
- lib_models_app_settings Community
- package_translatoo_state_translator_view_model_dart Community
- datetime Community
- dart_convert Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- package_translatoo_core_services_translation_backend_dart Community
- constants_app_constants_dart Community
- package_translatoo_core_services_app_exception_dart Community
- package_flutter_test_flutter_test_dart Community
- exception Community
- lib_core_services_mlkit_translation_backend Community
- int_get Community
- lib_core_constants_app_spacing Community
- lib_models_language Community
- app_exception_dart Community
- lib_core_services_translation_backend Community
- lib_models_model_state Community
- lib_ui_widgets_language_pill Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
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

## Communities (34 total, 0 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (58): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+50 more)

### Community 1 - "core_services_app_exception_dart Community"
Cohesion: 0.05
Nodes (49): ../../core/services/app_exception.dart, core/services/mlkit_translation_backend.dart, ../../core/services/model_manager_service.dart, core/services/storage_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart, core/theme/app_theme.dart, dart:async (+41 more)

### Community 2 - "color Community"
Cohesion: 0.06
Nodes (40): Color, ../../core/constants/app_constants.dart, ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, IconData, TranslatooApp, build, HistoryScreen (+32 more)

### Community 3 - "animationcontroller Community"
Cohesion: 0.05
Nodes (42): AnimationController, BorderRadius?, ChangeNotifier, ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, debug_models_screen.dart, history_screen.dart (+34 more)

### Community 4 - "appexception_get Community"
Cohesion: 0.05
Nodes (37): AppException? get, Language get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, clearSource, confirmDownloadAnyway, _debounce (+29 more)

### Community 5 - "connectivityplatform Community"
Cohesion: 0.06
Nodes (33): ConnectivityPlatform, dart:io, File, package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/constants/app_spacing.dart, package:translatoo/core/services/connectivity_service.dart, package:translatoo/core/theme/app_theme.dart, package:translatoo/main.dart (+25 more)

### Community 6 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (31): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, history, historyLimit (+23 more)

### Community 7 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (31): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+23 more)

### Community 8 - "appsettings_get Community"
Cohesion: 0.07
Nodes (27): AppSettings get, Duration, Future, dispose, _disposed, _favorites, flush, _flushing (+19 more)

### Community 9 - "dart_math Community"
Cohesion: 0.07
Nodes (25): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+17 more)

### Community 10 - "bool_get Community"
Cohesion: 0.10
Nodes (19): bool get, Connectivity, ../core/services/connectivity_service.dart, _apply, _connectivity, ConnectivityService, dispose, isOnline (+11 more)

### Community 11 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 12 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 13 - "package_translatoo_state_translator_view_model_dart Community"
Cohesion: 0.11
Nodes (18): package:translatoo/state/translator_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, complete, deleteModel, dispose, downloadModel, id (+10 more)

### Community 14 - "datetime Community"
Cohesion: 0.12
Nodes (15): DateTime, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+7 more)

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

### Community 19 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 20 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 21 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.18
Nodes (9): package:flutter_test/flutter_test.dart, package:translatoo/core/constants/app_strings.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/language_pair.dart, main, main, main (+1 more)

### Community 22 - "exception Community"
Cohesion: 0.17
Nodes (11): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+3 more)

### Community 23 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.18
Nodes (10): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+2 more)

### Community 24 - "int_get Community"
Cohesion: 0.20
Nodes (9): int get, language.dart, hashCode, LanguagePair, operator, source, swapped, target (+1 more)

### Community 25 - "lib_core_constants_app_spacing Community"
Cohesion: 0.20
Nodes (9): AppSpacing, lg, md, minTouchTarget, radius, sm, xl, xs (+1 more)

### Community 26 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, Language, mlKitCode, sttCode, tryFromCode, ttsCode

### Community 27 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, translation_backend.dart

### Community 28 - "lib_core_services_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart, String get

### Community 29 - "lib_models_model_state Community"
Cohesion: 0.36
Nodes (7): hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 30 - "lib_ui_widgets_language_pill Community"
Cohesion: 0.25
Nodes (7): build, language, onSelected, semanticLabel, ../../models/language.dart, String?, ValueChanged

### Community 31 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.29
Nodes (7): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _StubBackend, _EchoBackend

### Community 32 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 33 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **453 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+448 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `lib_models_language Community` to `core_services_app_exception_dart Community`, `color Community`, `appexception_get Community`, `lib_models_app_settings Community`, `datetime Community`, `int_get Community`, `lib_ui_widgets_language_pill Community`?**
  _High betweenness centrality (0.119) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `core_services_app_exception_dart Community`, `package_translatoo_core_services_translation_backend_dart Community`, `appexception_get Community`, `package_translatoo_core_services_app_exception_dart Community`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Why does `ModelManagerService` connect `core_services_app_exception_dart Community` to `completer Community`, `appexception_get Community`, `lib_core_services_model_manager_service Community`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _453 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.03389830508474576 - nodes in this community are weakly interconnected._
- **Should `core_services_app_exception_dart Community` be split into smaller, more focused modules?**
  _Cohesion score 0.05279034690799397 - nodes in this community are weakly interconnected._
- **Should `color Community` be split into smaller, more focused modules?**
  _Cohesion score 0.05507246376811594 - nodes in this community are weakly interconnected._