# Graph Report - .  (2026-09-02)

## Corpus Check
- 98 files · ~52,842 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1738 nodes · 2651 edges · 78 communities (76 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- changenotifier Community
- test_integration_conversational_flow_test Community
- appexception_get Community
- animationcontroller Community
- fakepermissionapi Community
- icon Community
- lib_core_services_stt_service Community
- lib_state_library_view_model_libraryviewmodel Community
- lib_core_services_model_manager_service Community
- lib_core_services_storage_service_storageservice Community
- core_constants_app_spacing_dart Community
- lib_state_speech_view_model Community
- fakeaudio Community
- appsettings_get Community
- core_services_tts_service_dart Community
- lib_core_constants_app_constants Community
- iconbutton Community
- errorcode_get Community
- package_translatoo_core_services_translation_service_dart Community
- dart_math Community
- fakettsengine Community
- core_services_flutter_tts_engine_dart Community
- lib_core_services_tts_service Community
- animation Community
- applifecyclelistener Community
- core_services_storage_service_dart Community
- exception Community
- fakeengine Community
- completer Community
- lib_core_services_translation_service Community
- lib_models_app_settings Community
- roundedrectangleborder Community
- core_services_app_exception_dart Community
- package_translatoo_ui_screens_history_screen_dart Community
- dart_convert Community
- dart_io Community
- lib_core_services_cloud_translation_backend_cloudtranslationapi Community
- constants_app_colors_dart Community
- fluttertts Community
- color Community
- package_translatoo_core_services_app_exception_dart Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- test_widgets_responsive_doubles Community
- package_fake_async_fake_async_dart Community
- audiorecorder Community
- dart_typed_data Community
- datetime Community
- lib_core_constants_app_typography Community
- lib_ui_widgets_translation_panel Community
- test_state_library_view_model_test Community
- connectivityplatform Community
- custompainter Community
- lib_core_services_whisper_stt_engine Community
- dart_async Community
- lib_core_constants_app_spacing Community
- lib_core_services_translation_backend_translationbackend Community
- package_translatoo_core_services_model_manager_service_dart Community
- package_translatoo_core_services_stt_service_dart Community
- bool_get Community
- connectivity Community
- lib_core_services_mic_permission_service Community
- package_translatoo_core_services_mic_permission_service_dart Community
- app_exception_dart Community
- duration Community
- level Community
- lib_core_services_flutter_tts_engine_flutterttsengine Community
- lib_core_utils_perf_trace Community
- int_get Community
- lib_models_language Community
- lib_core_services_tflite_translation_backend Community
- lib_core_services_translation_backend Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_services_stt_service_sttengine Community
- lib_core_constants_app_strings_appstrings Community
- lib_core_services_tts_service_ttsservice Community
- lib_models_language_pair_languagepair Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 28 edges
2. `TtsViewModel` - 22 edges
3. `ModelManagerService` - 21 edges
4. `TranslationBackend` - 20 edges
5. `ModelManagerApi` - 17 edges
6. `SpeechViewModel` - 17 edges
7. `AppException` - 13 edges
8. `StorageService` - 13 edges
9. `Language` - 12 edges
10. `SttAudioSource` - 9 edges

## Surprising Connections (you probably didn't know these)
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/services/model_manager_service_test.dart → lib/core/services/model_manager_service.dart
- `_ReadyModelApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/library_view_model_test.dart → lib/core/services/model_manager_service.dart
- `_LocalBackend` --implements--> `TranslationBackend`  [EXTRACTED]
  test/services/cloud_hybrid_test.dart → lib/core/services/translation_backend.dart
- `_EchoBackend` --implements--> `TranslationBackend`  [EXTRACTED]
  test/state/library_view_model_test.dart → lib/core/services/translation_backend.dart
- `_EchoBackend` --implements--> `TranslationBackend`  [EXTRACTED]
  test/state/translator_persistence_test.dart → lib/core/services/translation_backend.dart

## Import Cycles
- None detected.

## Communities (78 total, 2 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.02
Nodes (89): actionCancel, actionClear, actionClearAll, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway (+81 more)

### Community 1 - "changenotifier Community"
Cohesion: 0.06
Nodes (51): ChangeNotifier, ShareService, SettingsViewModel, SpeechViewModel, TranslatorViewModel, TtsViewModel, build, _VoiceDebugPanel (+43 more)

### Community 2 - "test_integration_conversational_flow_test Community"
Cohesion: 0.04
Nodes (49): _amplitude, backend, build, _bytes, configure, configuredLanguages, current, deleteModel (+41 more)

### Community 3 - "appexception_get Community"
Cohesion: 0.04
Nodes (47): AppException? get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, _clearStaleResult, confirmDownloadAnyway (+39 more)

### Community 4 - "animationcontroller Community"
Cohesion: 0.05
Nodes (44): AnimationController, BorderRadius?, HomeScreen, build, createState, enabled, height, isTarget (+36 more)

### Community 5 - "fakepermissionapi Community"
Cohesion: 0.05
Nodes (42): _FakePermissionApi, afterRequest, _amplitude, audio, backend, build, _bytes, current (+34 more)

### Community 6 - "icon Community"
Cohesion: 0.05
Nodes (42): Icon, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, _amplitude, audio, _bytes, cancel, deleteModel (+34 more)

### Community 7 - "lib_core_services_stt_service Community"
Cohesion: 0.05
Nodes (42): amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose, _engine, _failSession (+34 more)

### Community 8 - "lib_state_library_view_model_libraryviewmodel Community"
Cohesion: 0.06
Nodes (41): LibraryViewModel, build, _Chip, _confirmClearAll, _DeleteBackground, _deleteWithUndo, _FilterChips, label (+33 more)

### Community 9 - "lib_core_services_model_manager_service Community"
Cohesion: 0.05
Nodes (41): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+33 more)

### Community 10 - "lib_core_services_storage_service_storageservice Community"
Cohesion: 0.06
Nodes (37): StorageService, build, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/app_settings.dart, package:translatoo/state/library_view_model.dart, package:translatoo/state/settings_view_model.dart, package:translatoo/ui/screens/settings_screen.dart (+29 more)

### Community 11 - "core_constants_app_spacing_dart Community"
Cohesion: 0.06
Nodes (35): ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, ../../core/theme/app_theme.dart, IconData, TranslationRecord, build, ConnectionBadge, isOnline (+27 more)

### Community 12 - "lib_state_speech_view_model Community"
Cohesion: 0.05
Nodes (39): acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds, _elapsedTimer (+31 more)

### Community 13 - "fakeaudio Community"
Cohesion: 0.05
Nodes (37): _FakeAudio, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close, emit (+29 more)

### Community 14 - "appsettings_get Community"
Cohesion: 0.05
Nodes (35): AppSettings get, ../constants/app_constants.dart, dispose, _disposed, _favorites, flush, _flushing, _flushTimer (+27 more)

### Community 15 - "core_services_tts_service_dart Community"
Cohesion: 0.06
Nodes (34): ../core/services/tts_service.dart, acknowledgeError, _autoPlay, _clearError, dispose, _doubleTapWindow, _errorAction, _errorCode (+26 more)

### Community 16 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (34): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+26 more)

### Community 17 - "iconbutton Community"
Cohesion: 0.06
Nodes (30): IconButton, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/widgets/download_progress_card.dart, package:translatoo/ui/widgets/mode_button.dart, package:translatoo/ui/widgets/voice_block.dart, ReadingOrderTraversalPolicy, amplitude, complete (+22 more)

### Community 18 - "errorcode_get Community"
Cohesion: 0.07
Nodes (28): ErrorCode? get, acknowledgeError, addRecord, canUndo, clearHistory, delete, dispose, _enforceLimit (+20 more)

### Community 19 - "package_translatoo_core_services_translation_service_dart Community"
Cohesion: 0.07
Nodes (26): package:translatoo/core/services/translation_service.dart, package:translatoo/models/language_pair.dart, package:translatoo/state/translator_view_model.dart, main, deleteModel, dispose, downloadModel, _EchoBackend (+18 more)

### Community 20 - "dart_math Community"
Cohesion: 0.07
Nodes (26): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+18 more)

### Community 21 - "fakettsengine Community"
Cohesion: 0.07
Nodes (26): _FakeTtsEngine, package:translatoo/state/tts_view_model.dart, build, configure, deleteModel, dispose, downloadModel, emit (+18 more)

### Community 22 - "core_services_flutter_tts_engine_dart Community"
Cohesion: 0.08
Nodes (25): core/services/flutter_tts_engine.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, ../../core/services/share_service.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart (+17 more)

### Community 23 - "lib_core_services_tts_service Community"
Cohesion: 0.08
Nodes (24): configure, dispose, _engine, _engineSub, ensureVoice, events, hashCode, isLanguageAvailable (+16 more)

### Community 24 - "animation Community"
Cohesion: 0.09
Nodes (22): Animation, animation, build, color, createState, dispose, maybe, onPressed (+14 more)

### Community 25 - "applifecyclelistener Community"
Cohesion: 0.09
Nodes (23): AppLifecycleListener, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, dispose, _HomeScreenState (+15 more)

### Community 26 - "core_services_storage_service_dart Community"
Cohesion: 0.08
Nodes (23): ../core/services/storage_service.dart, double get, Language? get, autoPlay, setAutoPlay, setSourceLanguage, setTargetLanguage, setThemeMode (+15 more)

### Community 27 - "exception Community"
Cohesion: 0.09
Nodes (21): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+13 more)

### Community 28 - "fakeengine Community"
Cohesion: 0.09
Nodes (22): _FakeEngine, configure, configuredLanguages, dispose, emit, engine, errors, _events (+14 more)

### Community 29 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 30 - "lib_core_services_translation_service Community"
Cohesion: 0.10
Nodes (20): activeBackend, _cloud, cloudActive, dispose, _fallback, _fallbackEnabled, isReady, lastResultWasLocal (+12 more)

### Community 31 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 32 - "roundedrectangleborder Community"
Cohesion: 0.10
Nodes (20): RoundedRectangleBorder, ScaffoldState, amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel (+12 more)

### Community 33 - "core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (18): ../../core/services/app_exception.dart, ../../core/services/model_manager_service.dart, ModelManagerService, DebugModelsScreen, language, _ModelTile, state, build (+10 more)

### Community 34 - "package_translatoo_ui_screens_history_screen_dart Community"
Cohesion: 0.10
Nodes (19): package:translatoo/ui/screens/history_screen.dart, package:translatoo/ui/widgets/history_card.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady (+11 more)

### Community 35 - "dart_convert Community"
Cohesion: 0.13
Nodes (15): dart:convert, Map, package:flutter_test/flutter_test.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/models/language.dart, package:translatoo/models/translation_record.dart, main, main (+7 more)

### Community 36 - "dart_io Community"
Cohesion: 0.12
Nodes (14): dart:io, File, package:translatoo/core/constants/app_spacing.dart, package:translatoo/core/constants/app_strings.dart, package:translatoo/core/theme/app_theme.dart, package:translatoo/ui/widgets/connection_badge.dart, dartFiles, main (+6 more)

### Community 37 - "lib_core_services_cloud_translation_backend_cloudtranslationapi Community"
Cohesion: 0.11
Nodes (18): CloudTranslationApi, package:translatoo/core/services/cloud_translation_backend.dart, api, build, calls, delay, dispose, error (+10 more)

### Community 38 - "constants_app_colors_dart Community"
Cohesion: 0.12
Nodes (17): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppSemanticColors, AppTheme, _build, cjkFallback, copyWith (+9 more)

### Community 39 - "fluttertts Community"
Cohesion: 0.11
Nodes (17): FlutterTts, _active, _androidRate, configure, dispose, _events, _hasStarted, isLanguageAvailable (+9 more)

### Community 40 - "color Community"
Cohesion: 0.14
Nodes (15): Color?, ../../core/constants/app_constants.dart, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator (+7 more)

### Community 41 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.12
Nodes (15): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/translation_backend.dart, main, beginCapture, dispose, id, isModelDownloaded, isReady (+7 more)

### Community 42 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 43 - "test_widgets_responsive_doubles Community"
Cohesion: 0.12
Nodes (16): amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel, _events, id (+8 more)

### Community 44 - "package_fake_async_fake_async_dart Community"
Cohesion: 0.12
Nodes (14): package:fake_async/fake_async.dart, package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, package:translatoo/models/model_state.dart, completeDownload, deleteModel, downloadModel, failDownload (+6 more)

### Community 45 - "audiorecorder Community"
Cohesion: 0.13
Nodes (14): AudioRecorder, _amplitude, _amplitudeInterval, _amplitudeSub, dispose, _floorDb, _listenToAmplitude, normalize (+6 more)

### Community 46 - "dart_typed_data Community"
Cohesion: 0.13
Nodes (14): dart:typed_data, Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation (+6 more)

### Community 47 - "datetime Community"
Cohesion: 0.13
Nodes (14): DateTime?, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+6 more)

### Community 48 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 49 - "lib_ui_widgets_translation_panel Community"
Cohesion: 0.13
Nodes (14): actions, build, child, expandChild, footer, header, languageLabel, onTapLanguage (+6 more)

### Community 50 - "test_state_library_view_model_test Community"
Cohesion: 0.13
Nodes (14): deleteModel, dispose, downloadModel, _EchoBackend, id, isModelDownloaded, isReady, main (+6 more)

### Community 51 - "connectivityplatform Community"
Cohesion: 0.14
Nodes (13): ConnectivityPlatform, List, package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/services/connectivity_service.dart, checkConnectivity, _drainEventLoop, events, _FakePlatform (+5 more)

### Community 52 - "custompainter Community"
Cohesion: 0.14
Nodes (13): CustomPainter, _barWidth, build, color, _gap, height, levels, paint (+5 more)

### Community 53 - "lib_core_services_whisper_stt_engine Community"
Cohesion: 0.14
Nodes (13): _controller, feed, _noAudio, partials, _session, startSession, stop, package:whisper_ggml/whisper_ggml.dart (+5 more)

### Community 54 - "dart_async Community"
Cohesion: 0.15
Nodes (12): dart:async, dispose, id, isModelDownloaded, isReady, _mapError, MlKitTranslationBackend, _toPlugin (+4 more)

### Community 55 - "lib_core_constants_app_spacing Community"
Cohesion: 0.15
Nodes (12): AppSpacing, lg, md, minTouchTarget, radius, radiusLg, radiusMd, radiusPill (+4 more)

### Community 56 - "lib_core_services_translation_backend_translationbackend Community"
Cohesion: 0.15
Nodes (13): TranslationBackend, _EchoBackend, _EchoBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _EchoBackend, _CountingBackend (+5 more)

### Community 57 - "package_translatoo_core_services_model_manager_service_dart Community"
Cohesion: 0.15
Nodes (12): package:translatoo/core/services/model_manager_service.dart, package:translatoo/ui/screens/model_manager_screen.dart, complete, deleteModel, downloadModel, installed, isModelDownloaded, main (+4 more)

### Community 58 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.15
Nodes (12): package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/tts_service.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, package:translatoo/ui/screens/translate_screen.dart, responsive_doubles.dart, Scaffold, connectivity (+4 more)

### Community 59 - "bool_get Community"
Cohesion: 0.17
Nodes (10): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart (+2 more)

### Community 60 - "connectivity Community"
Cohesion: 0.17
Nodes (11): Connectivity, _apply, _connectivity, dispose, isOnline, isOnMobileData, start, _subscription (+3 more)

### Community 61 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 62 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 63 - "app_exception_dart Community"
Cohesion: 0.22
Nodes (9): app_exception.dart, _platform, PlatformShare, SharePlatform, shareText, shareTranslation, ../../models/language.dart, package:share_plus/share_plus.dart (+1 more)

### Community 64 - "duration Community"
Cohesion: 0.20
Nodes (9): Duration, _api, CloudTranslationBackend, dispose, id, isModelDownloaded, isReady, _timeout (+1 more)

### Community 65 - "level Community"
Cohesion: 0.24
Nodes (10): Level, RecordAudioSource, SttAudioSource, _FakeAudio, _FakeAudio, _FakeAudio, _SilentAudio, _FakeAudio (+2 more)

### Community 66 - "lib_core_services_flutter_tts_engine_flutterttsengine Community"
Cohesion: 0.22
Nodes (10): FlutterTtsEngine, TtsEngine, TtsEvent, _FakeTtsEngine, _FakeEngine, _FakeTtsEngine, _SilentTtsEngine, SilentTtsEngine (+2 more)

### Community 67 - "lib_core_utils_perf_trace Community"
Cohesion: 0.20
Nodes (9): budget, budgetMs, label, PerfBudget, PerfTrace, start, stop, _watch (+1 more)

### Community 68 - "int_get Community"
Cohesion: 0.22
Nodes (8): int get, language.dart, hashCode, operator, source, swapped, target, toString

### Community 69 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, Language, mlKitCode, sttCode, tryFromCode, ttsCode

### Community 70 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, TfliteTranslationBackend, translate, translation_backend.dart

### Community 71 - "lib_core_services_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart, String get

### Community 72 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.29
Nodes (7): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 73 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.33
Nodes (6): MicPermissionApi, PlatformMicPermissionApi, _FakePermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 74 - "lib_core_services_stt_service_sttengine Community"
Cohesion: 0.33
Nodes (6): SttEngine, WhisperSttEngine, _FakeEngine, _FakeEngine, _FakeEngine, _FakeEngine

### Community 75 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

## Knowledge Gaps
- **1229 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+1224 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TranslatorViewModel` connect `changenotifier Community` to `test_integration_conversational_flow_test Community`, `appexception_get Community`, `package_translatoo_ui_screens_history_screen_dart Community`, `fakepermissionapi Community`, `icon Community`, `lib_state_library_view_model_libraryviewmodel Community`, `lib_core_services_storage_service_storageservice Community`, `lib_core_services_tts_service_ttsservice Community`, `lib_state_speech_view_model Community`, `core_services_tts_service_dart Community`, `errorcode_get Community`, `fakettsengine Community`, `core_services_flutter_tts_engine_dart Community`, `completer Community`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `changenotifier Community`, `appexception_get Community`, `lib_core_services_cloud_translation_backend_cloudtranslationapi Community`, `package_translatoo_core_services_app_exception_dart Community`, `lib_core_services_storage_service_storageservice Community`, `package_translatoo_core_services_whisper_model_installer_dart Community`, `package_fake_async_fake_async_dart Community`, `fakeaudio Community`, `fakeengine Community`, `package_translatoo_core_services_mic_permission_service_dart Community`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `Language` connect `lib_models_language Community` to `core_services_app_exception_dart Community`, `changenotifier Community`, `appexception_get Community`, `int_get Community`, `animationcontroller Community`, `lib_state_library_view_model_libraryviewmodel Community`, `color Community`, `core_services_tts_service_dart Community`, `datetime Community`, `lib_models_app_settings Community`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _1229 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.022222222222222223 - nodes in this community are weakly interconnected._
- **Should `changenotifier Community` be split into smaller, more focused modules?**
  _Cohesion score 0.058069381598793365 - nodes in this community are weakly interconnected._
- **Should `test_integration_conversational_flow_test Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._