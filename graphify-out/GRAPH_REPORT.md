# Graph Report - .  (2026-09-01)

## Corpus Check
- 56 files · ~20,813 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 829 nodes · 1103 edges · 50 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- appexception_get Community
- connectivityplatform Community
- lib_core_services_stt_service Community
- lib_core_constants_app_constants Community
- package_translatoo_core_services_stt_service_dart Community
- lib_core_services_model_manager_service Community
- appsettings_get Community
- dart_math Community
- core_services_app_exception_dart Community
- completer Community
- lib_models_app_settings Community
- core_constants_app_spacing_dart Community
- package_translatoo_state_translator_view_model_dart Community
- core_services_mlkit_translation_backend_dart Community
- dart_typed_data Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- datetime Community
- debug_models_screen_dart Community
- future Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- package_translatoo_core_services_translation_backend_dart Community
- animationcontroller Community
- constants_app_constants_dart Community
- dart_convert Community
- package_translatoo_core_services_app_exception_dart Community
- package_flutter_test_flutter_test_dart Community
- connectivity Community
- constants_app_colors_dart Community
- exception Community
- lib_core_services_mlkit_translation_backend Community
- core_services_model_manager_service_dart Community
- int_get Community
- lib_core_constants_app_spacing Community
- bool_get Community
- color Community
- lib_models_language Community
- app_exception_dart Community
- dart_io Community
- lib_core_services_tflite_translation_backend Community
- lib_models_language_language Community
- lib_models_model_state Community
- icondata Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
- changenotifier Community
- lib_core_constants_app_strings_appstrings Community
- lib_core_services_stt_service_sttenginesession Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- package_translatoo_core_constants_app_constants_dart Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 12 edges
2. `ModelManagerService` - 11 edges
3. `AppException` - 8 edges
4. `TranslationBackend` - 8 edges
5. `Language` - 8 edges
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

## Communities (50 total, 0 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (58): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+50 more)

### Community 1 - "appexception_get Community"
Cohesion: 0.05
Nodes (38): AppException? get, Language get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, confirmDownloadAnyway (+30 more)

### Community 2 - "connectivityplatform Community"
Cohesion: 0.06
Nodes (36): ConnectivityPlatform, actions, build, child, expandChild, footer, leading, List (+28 more)

### Community 3 - "lib_core_services_stt_service Community"
Cohesion: 0.05
Nodes (37): _armPauseTimer, _audio, _audioSub, cancel, dispose, _engine, _failSession, feed (+29 more)

### Community 4 - "lib_core_constants_app_constants Community"
Cohesion: 0.05
Nodes (36): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+28 more)

### Community 5 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.06
Nodes (34): package:translatoo/core/services/stt_service.dart, static final Uint8List, audio, _bytes, close, emit, emitPartial, engine (+26 more)

### Community 6 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (31): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+23 more)

### Community 7 - "appsettings_get Community"
Cohesion: 0.07
Nodes (26): AppSettings get, Duration, dispose, _disposed, _favorites, flush, _flushing, _flushTimer (+18 more)

### Community 8 - "dart_math Community"
Cohesion: 0.07
Nodes (25): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+17 more)

### Community 9 - "core_services_app_exception_dart Community"
Cohesion: 0.11
Nodes (23): ../../core/services/app_exception.dart, TranslatorViewModel, build, _controller, _copyTranslation, createState, _DestinationSection, didChangeDependencies (+15 more)

### Community 10 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 11 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 12 - "core_constants_app_spacing_dart Community"
Cohesion: 0.13
Nodes (17): ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, TranslatooApp, build, HistoryScreen, build, SettingsScreen, _OriginFooter (+9 more)

### Community 13 - "package_translatoo_state_translator_view_model_dart Community"
Cohesion: 0.11
Nodes (18): package:translatoo/state/translator_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, complete, deleteModel, dispose, downloadModel, id (+10 more)

### Community 14 - "core_services_mlkit_translation_backend_dart Community"
Cohesion: 0.11
Nodes (17): core/services/mlkit_translation_backend.dart, core/services/storage_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart, core/theme/app_theme.dart, StorageService, build, connectivity (+9 more)

### Community 15 - "dart_typed_data Community"
Cohesion: 0.12
Nodes (16): dart:typed_data, SttEngine, _controller, feed, _noAudio, partials, _session, startSession (+8 more)

### Community 16 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 17 - "datetime Community"
Cohesion: 0.12
Nodes (15): DateTime, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+7 more)

### Community 18 - "debug_models_screen_dart Community"
Cohesion: 0.14
Nodes (14): debug_models_screen.dart, history_screen.dart, createState, HomeScreen, _HomeScreenState, _index, _screens, package:provider/provider.dart (+6 more)

### Community 19 - "future Community"
Cohesion: 0.13
Nodes (14): Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation, modelsDirectory (+6 more)

### Community 20 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 21 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 22 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.13
Nodes (14): package:translatoo/core/services/translation_backend.dart, package:translatoo/core/services/translation_service.dart, beginCapture, dispose, id, isModelDownloaded, isReady, main (+6 more)

### Community 23 - "animationcontroller Community"
Cohesion: 0.15
Nodes (13): AnimationController, BorderRadius?, borderRadius, build, _controller, createState, dispose, height (+5 more)

### Community 24 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 25 - "dart_convert Community"
Cohesion: 0.15
Nodes (12): dart:convert, package:fake_async/fake_async.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/translation_record.dart, main, _record, getInstance (+4 more)

### Community 26 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 27 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.18
Nodes (9): package:flutter_test/flutter_test.dart, package:translatoo/core/constants/app_strings.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/language_pair.dart, main, main, main (+1 more)

### Community 28 - "connectivity Community"
Cohesion: 0.17
Nodes (11): Connectivity, _apply, _connectivity, dispose, isOnline, isOnMobileData, start, _subscription (+3 more)

### Community 29 - "constants_app_colors_dart Community"
Cohesion: 0.17
Nodes (11): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppTheme, _build, cjkFallback, dark, light (+3 more)

### Community 30 - "exception Community"
Cohesion: 0.17
Nodes (11): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+3 more)

### Community 31 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+3 more)

### Community 32 - "core_services_model_manager_service_dart Community"
Cohesion: 0.27
Nodes (9): ../../core/services/model_manager_service.dart, dart:async, ModelManagerService, build, DebugModelsScreen, language, _ModelTile, state (+1 more)

### Community 33 - "int_get Community"
Cohesion: 0.20
Nodes (9): int get, language.dart, hashCode, LanguagePair, operator, source, swapped, target (+1 more)

### Community 34 - "lib_core_constants_app_spacing Community"
Cohesion: 0.20
Nodes (9): AppSpacing, lg, md, minTouchTarget, radius, sm, xl, xs (+1 more)

### Community 35 - "bool_get Community"
Cohesion: 0.22
Nodes (8): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart

### Community 36 - "color Community"
Cohesion: 0.22
Nodes (8): Color, ../../core/constants/app_constants.dart, build, language, onCancel, onDownload, state, VoidCallback?

### Community 37 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, mlKitCode, sttCode, tryFromCode, ttsCode, String get

### Community 38 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart

### Community 39 - "dart_io Community"
Cohesion: 0.25
Nodes (6): dart:io, File, package:translatoo/core/theme/app_theme.dart, main, main, stylesOf

### Community 40 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, translate, ../../models/language.dart, translation_backend.dart

### Community 41 - "lib_models_language_language Community"
Cohesion: 0.25
Nodes (7): Language, build, language, onSelected, semanticLabel, String?, ValueChanged

### Community 42 - "lib_models_model_state Community"
Cohesion: 0.36
Nodes (7): hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 43 - "icondata Community"
Cohesion: 0.29
Nodes (6): IconData, build, icon, message, PlaceholderPanel, title

### Community 44 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.29
Nodes (7): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _StubBackend, _EchoBackend

### Community 45 - "changenotifier Community"
Cohesion: 0.50
Nodes (4): ChangeNotifier, ConnectionViewModel, build, MaterialPageRoute

### Community 46 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 47 - "lib_core_services_stt_service_sttenginesession Community"
Cohesion: 0.50
Nodes (4): SttEngineSession, _WhisperSession, Partial, _FakeSession

### Community 48 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.50
Nodes (4): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _FakeStorage

### Community 49 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **555 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+550 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `lib_models_language_language Community` to `core_services_model_manager_service_dart Community`, `int_get Community`, `appexception_get Community`, `color Community`, `lib_models_language Community`, `lib_models_app_settings Community`, `datetime Community`?**
  _High betweenness centrality (0.080) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `appexception_get Community`, `package_translatoo_core_services_stt_service_dart Community`, `core_services_app_exception_dart Community`, `package_translatoo_core_services_whisper_model_installer_dart Community`, `package_translatoo_core_services_translation_backend_dart Community`, `package_translatoo_core_services_app_exception_dart Community`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `ModelManagerService` connect `core_services_model_manager_service_dart Community` to `appexception_get Community`, `lib_core_services_model_manager_service Community`, `core_services_app_exception_dart Community`, `completer Community`, `core_services_mlkit_translation_backend_dart Community`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _555 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.03389830508474576 - nodes in this community are weakly interconnected._
- **Should `appexception_get Community` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Should `connectivityplatform Community` be split into smaller, more focused modules?**
  _Cohesion score 0.058029689608636977 - nodes in this community are weakly interconnected._