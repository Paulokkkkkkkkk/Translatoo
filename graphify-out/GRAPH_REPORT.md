# Graph Report - .  (2026-09-03)

## Corpus Check
- 100 files · ~54,392 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1763 nodes · 2681 edges · 80 communities (79 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- color Community
- appexception_get Community
- test_integration_conversational_flow_test Community
- fakepermissionapi Community
- icon Community
- lib_core_services_model_manager_service Community
- custompainter Community
- dart_convert Community
- iconbutton Community
- lib_state_speech_view_model Community
- lib_core_services_share_service_shareservice Community
- fakeaudio Community
- lib_core_services_stt_service Community
- lib_core_constants_app_constants Community
- lib_state_tts_view_model Community
- lib_ui_widgets_language_bar Community
- core_services_flutter_tts_engine_dart Community
- errorcode_get Community
- dart_math Community
- lib_core_services_text_chunker Community
- lib_core_services_tts_service Community
- lib_ui_screens_history_screen Community
- applifecyclelistener Community
- core_services_app_exception_dart Community
- core_services_storage_service_dart Community
- animation Community
- appsettings_get Community
- fakeengine Community
- changenotifier Community
- completer Community
- lib_core_services_pinyin_service Community
- lib_core_services_translation_service Community
- lib_models_app_settings Community
- roundedrectangleborder Community
- package_translatoo_ui_screens_history_screen_dart Community
- dart_io Community
- lib_core_services_cloud_translation_backend_cloudtranslationapi Community
- constants_app_colors_dart Community
- fluttertts Community
- lib_state_speech_view_model_speechviewmodel Community
- package_flutter_test_flutter_test_dart Community
- package_translatoo_core_constants_app_constants_dart Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- test_widgets_responsive_doubles Community
- lib_core_services_tflite_translation_backend Community
- audiorecorder Community
- datetime Community
- future Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_backend_translationbackend Community
- lib_ui_widgets_translation_panel Community
- package_translatoo_state_translator_view_model_dart Community
- connectivityplatform Community
- dart_typed_data Community
- exception Community
- package_translatoo_core_services_translation_backend_dart Community
- package_translatoo_core_services_translation_service_dart Community
- test_integration_library_flow_test Community
- connectivity Community
- lib_core_constants_app_spacing Community
- package_translatoo_core_services_stt_service_dart Community
- bool_get Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- package_translatoo_core_services_mic_permission_service_dart Community
- constants_app_constants_dart Community
- app_exception_dart Community
- lib_core_services_app_exception Community
- lib_core_services_flutter_tts_engine_flutterttsengine Community
- lib_core_utils_perf_trace Community
- int_get Community
- lib_models_language Community
- language_dart Community
- lib_core_services_stt_service_sttenginesession Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_services_stt_service_sttengine Community
- lib_core_constants_app_strings_appstrings Community
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
- `_ReadyApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/translator_persistence_test.dart → lib/core/services/model_manager_service.dart
- `_GateApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/widgets/model_manager_screen_test.dart → lib/core/services/model_manager_service.dart
- `_LocalBackend` --implements--> `TranslationBackend`  [EXTRACTED]
  test/services/cloud_hybrid_test.dart → lib/core/services/translation_backend.dart
- `_FakePermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/integration/conversational_flow_test.dart → lib/core/services/mic_permission_service.dart
- `_FakeApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/services/mic_permission_service_test.dart → lib/core/services/mic_permission_service.dart

## Import Cycles
- None detected.

## Communities (80 total, 1 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.02
Nodes (89): actionCancel, actionClear, actionClearAll, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway (+81 more)

### Community 1 - "color Community"
Cohesion: 0.05
Nodes (45): Color?, ../../core/constants/app_constants.dart, ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, ../../core/theme/app_theme.dart, IconData, TranslationRecord, build (+37 more)

### Community 2 - "appexception_get Community"
Cohesion: 0.04
Nodes (50): AppException? get, ../core/services/pinyin_service.dart, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, _clearStaleResult (+42 more)

### Community 3 - "test_integration_conversational_flow_test Community"
Cohesion: 0.04
Nodes (49): _amplitude, backend, build, _bytes, configure, configuredLanguages, current, deleteModel (+41 more)

### Community 4 - "fakepermissionapi Community"
Cohesion: 0.05
Nodes (42): _FakePermissionApi, afterRequest, _amplitude, audio, backend, build, _bytes, current (+34 more)

### Community 5 - "icon Community"
Cohesion: 0.05
Nodes (42): Icon, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, _amplitude, audio, _bytes, cancel, deleteModel (+34 more)

### Community 6 - "lib_core_services_model_manager_service Community"
Cohesion: 0.05
Nodes (41): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+33 more)

### Community 7 - "custompainter Community"
Cohesion: 0.05
Nodes (39): CustomPainter, _FakeTtsEngine, _barWidth, build, color, _gap, height, levels (+31 more)

### Community 8 - "dart_convert Community"
Cohesion: 0.07
Nodes (34): dart:convert, Map, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/translation_record.dart, package:translatoo/state/library_view_model.dart (+26 more)

### Community 9 - "iconbutton Community"
Cohesion: 0.05
Nodes (40): IconButton, Level, RecordAudioSource, SttAudioSource, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/widgets/download_progress_card.dart, package:translatoo/ui/widgets/mode_button.dart, package:translatoo/ui/widgets/voice_block.dart (+32 more)

### Community 10 - "lib_state_speech_view_model Community"
Cohesion: 0.05
Nodes (39): acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds, _elapsedTimer (+31 more)

### Community 11 - "lib_core_services_share_service_shareservice Community"
Cohesion: 0.07
Nodes (38): ShareService, TranslatorViewModel, HistoryScreen, _reopen, _controller, _copyTranslation, createState, _DestinationPanel (+30 more)

### Community 12 - "fakeaudio Community"
Cohesion: 0.05
Nodes (37): _FakeAudio, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close, emit (+29 more)

### Community 13 - "lib_core_services_stt_service Community"
Cohesion: 0.05
Nodes (36): amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose, _engine, _failSession (+28 more)

### Community 14 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (34): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+26 more)

### Community 15 - "lib_state_tts_view_model Community"
Cohesion: 0.06
Nodes (33): acknowledgeError, _autoPlay, _clearError, dispose, _doubleTapWindow, _errorAction, _errorCode, _errorLanguage (+25 more)

### Community 16 - "lib_ui_widgets_language_bar Community"
Cohesion: 0.07
Nodes (33): build, createState, enabled, height, isTarget, language, leadingGap, onPressed (+25 more)

### Community 17 - "core_services_flutter_tts_engine_dart Community"
Cohesion: 0.08
Nodes (29): core/services/flutter_tts_engine.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, ../../core/services/share_service.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart (+21 more)

### Community 18 - "errorcode_get Community"
Cohesion: 0.07
Nodes (28): ErrorCode? get, acknowledgeError, addRecord, canUndo, clearHistory, delete, dispose, _enforceLimit (+20 more)

### Community 19 - "dart_math Community"
Cohesion: 0.07
Nodes (26): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+18 more)

### Community 20 - "lib_core_services_text_chunker Community"
Cohesion: 0.08
Nodes (24): _breakUnits, chunks, chunkText, _findCutIndex, high, index, low, max (+16 more)

### Community 21 - "lib_core_services_tts_service Community"
Cohesion: 0.08
Nodes (24): configure, dispose, _engine, _engineSub, ensureVoice, events, hashCode, isLanguageAvailable (+16 more)

### Community 22 - "lib_ui_screens_history_screen Community"
Cohesion: 0.09
Nodes (24): build, _Chip, _confirmClearAll, _DeleteBackground, _deleteWithUndo, _FilterChips, label, onChanged (+16 more)

### Community 23 - "applifecyclelistener Community"
Cohesion: 0.09
Nodes (23): AppLifecycleListener, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, dispose, HomeScreen (+15 more)

### Community 24 - "core_services_app_exception_dart Community"
Cohesion: 0.12
Nodes (22): ../../core/services/app_exception.dart, ../../core/services/model_manager_service.dart, ModelManagerService, TtsViewModel, build, DebugModelsScreen, language, _ModelTile (+14 more)

### Community 25 - "core_services_storage_service_dart Community"
Cohesion: 0.08
Nodes (23): ../core/services/storage_service.dart, double get, Language? get, autoPlay, setAutoPlay, setSourceLanguage, setTargetLanguage, setThemeMode (+15 more)

### Community 26 - "animation Community"
Cohesion: 0.09
Nodes (21): Animation, AnimationController, BorderRadius?, animation, build, color, createState, dispose (+13 more)

### Community 27 - "appsettings_get Community"
Cohesion: 0.09
Nodes (22): AppSettings get, dispose, _disposed, _favorites, flush, _flushing, _flushTimer, _history (+14 more)

### Community 28 - "fakeengine Community"
Cohesion: 0.09
Nodes (22): _FakeEngine, configure, configuredLanguages, dispose, emit, engine, errors, _events (+14 more)

### Community 29 - "changenotifier Community"
Cohesion: 0.11
Nodes (20): ChangeNotifier, LibraryViewModel, SettingsViewModel, appVersion, _confirmClearHistory, label, _LanguageTile, max (+12 more)

### Community 30 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 31 - "lib_core_services_pinyin_service Community"
Cohesion: 0.10
Nodes (19): _doubleSpace, engine, _han, PackagePinyinEngine, PinyinEngine, PinyinService, romanize, romanizeFor (+11 more)

### Community 32 - "lib_core_services_translation_service Community"
Cohesion: 0.10
Nodes (20): activeBackend, _cloud, cloudActive, dispose, _fallback, _fallbackEnabled, isReady, lastResultWasLocal (+12 more)

### Community 33 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 34 - "roundedrectangleborder Community"
Cohesion: 0.10
Nodes (20): RoundedRectangleBorder, ScaffoldState, amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel (+12 more)

### Community 35 - "package_translatoo_ui_screens_history_screen_dart Community"
Cohesion: 0.10
Nodes (19): package:translatoo/ui/screens/history_screen.dart, package:translatoo/ui/widgets/history_card.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady (+11 more)

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

### Community 40 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.12
Nodes (17): SpeechViewModel, _onMicPressed, _OriginFooter, _showBlockedDialog, _toggleMode, build, color, height (+9 more)

### Community 41 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.12
Nodes (15): package:flutter_test/flutter_test.dart, package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/core/services/share_service.dart, String?, main, main, calls (+7 more)

### Community 42 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.12
Nodes (15): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main, deleteModel, dispose, downloadModel, id, isModelDownloaded (+7 more)

### Community 43 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 44 - "test_widgets_responsive_doubles Community"
Cohesion: 0.12
Nodes (16): amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel, _events, id (+8 more)

### Community 45 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.13
Nodes (14): dispose, id, isModelDownloaded, isReady, TfliteTranslationBackend, translate, dispose, id (+6 more)

### Community 46 - "audiorecorder Community"
Cohesion: 0.13
Nodes (14): AudioRecorder, _amplitude, _amplitudeInterval, _amplitudeSub, dispose, _floorDb, _listenToAmplitude, normalize (+6 more)

### Community 47 - "datetime Community"
Cohesion: 0.13
Nodes (14): DateTime?, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+6 more)

### Community 48 - "future Community"
Cohesion: 0.13
Nodes (14): Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation, modelsDirectory (+6 more)

### Community 49 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 50 - "lib_core_services_translation_backend_translationbackend Community"
Cohesion: 0.13
Nodes (15): TranslationBackend, _EchoBackend, _EchoBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _EchoBackend, _EchoBackend (+7 more)

### Community 51 - "lib_ui_widgets_translation_panel Community"
Cohesion: 0.13
Nodes (14): actions, build, child, expandChild, footer, header, languageLabel, onTapLanguage (+6 more)

### Community 52 - "package_translatoo_state_translator_view_model_dart Community"
Cohesion: 0.13
Nodes (14): package:translatoo/state/translator_view_model.dart, backend, deleteModel, dispose, downloadModel, error, id, installed (+6 more)

### Community 53 - "connectivityplatform Community"
Cohesion: 0.14
Nodes (13): ConnectivityPlatform, package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/services/connectivity_service.dart, Stream, checkConnectivity, _drainEventLoop, events, _FakePlatform (+5 more)

### Community 54 - "dart_typed_data Community"
Cohesion: 0.14
Nodes (13): dart:typed_data, _controller, feed, _noAudio, partials, _session, startSession, stop (+5 more)

### Community 55 - "exception Community"
Cohesion: 0.14
Nodes (13): Exception, AppException, package:fake_async/fake_async.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, completeDownload, deleteModel, downloadModel (+5 more)

### Community 56 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/translation_backend.dart, package:translatoo/models/language_pair.dart, main, deleteModel, dispose, downloadModel, id, isModelDownloaded (+4 more)

### Community 57 - "package_translatoo_core_services_translation_service_dart Community"
Cohesion: 0.14
Nodes (13): package:translatoo/core/services/translation_service.dart, beginCapture, dispose, id, isModelDownloaded, isReady, main, primary (+5 more)

### Community 58 - "test_integration_library_flow_test Community"
Cohesion: 0.14
Nodes (13): deleteModel, dispose, downloadCalls, downloadModel, id, installed, isModelDownloaded, isReady (+5 more)

### Community 59 - "connectivity Community"
Cohesion: 0.15
Nodes (12): Connectivity, dart:async, _apply, _connectivity, dispose, isOnline, isOnMobileData, start (+4 more)

### Community 60 - "lib_core_constants_app_spacing Community"
Cohesion: 0.15
Nodes (12): AppSpacing, lg, md, minTouchTarget, radius, radiusLg, radiusMd, radiusPill (+4 more)

### Community 61 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.15
Nodes (12): package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/tts_service.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, package:translatoo/ui/screens/translate_screen.dart, responsive_doubles.dart, Scaffold, connectivity (+4 more)

### Community 62 - "bool_get Community"
Cohesion: 0.17
Nodes (10): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart (+2 more)

### Community 63 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 64 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, MlKitTranslationBackend, _toPlugin, translate (+3 more)

### Community 65 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 66 - "constants_app_constants_dart Community"
Cohesion: 0.18
Nodes (10): ../constants/app_constants.dart, Duration, _api, CloudTranslationBackend, dispose, id, isModelDownloaded, isReady (+2 more)

### Community 67 - "app_exception_dart Community"
Cohesion: 0.22
Nodes (9): app_exception.dart, _platform, PlatformShare, SharePlatform, shareText, shareTranslation, ../../models/language.dart, package:share_plus/share_plus.dart (+1 more)

### Community 68 - "lib_core_services_app_exception Community"
Cohesion: 0.20
Nodes (9): cause, code, ErrorCode, stackTrace, SuggestedAction, toString, wireCode, Object? (+1 more)

### Community 69 - "lib_core_services_flutter_tts_engine_flutterttsengine Community"
Cohesion: 0.22
Nodes (10): FlutterTtsEngine, TtsEngine, TtsEvent, _FakeTtsEngine, _FakeEngine, _FakeTtsEngine, _SilentTtsEngine, SilentTtsEngine (+2 more)

### Community 70 - "lib_core_utils_perf_trace Community"
Cohesion: 0.20
Nodes (9): budget, budgetMs, label, PerfBudget, PerfTrace, start, stop, _watch (+1 more)

### Community 71 - "int_get Community"
Cohesion: 0.31
Nodes (8): int get, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 72 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, Language, mlKitCode, sttCode, tryFromCode, ttsCode

### Community 73 - "language_dart Community"
Cohesion: 0.25
Nodes (7): language.dart, hashCode, operator, source, swapped, target, toString

### Community 74 - "lib_core_services_stt_service_sttenginesession Community"
Cohesion: 0.43
Nodes (7): SttEngineSession, _WhisperSession, Partial, _FakeSession, _FakeSession, _FakeSession, _FakeSession

### Community 75 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.29
Nodes (7): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 76 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.33
Nodes (6): MicPermissionApi, PlatformMicPermissionApi, _FakePermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 77 - "lib_core_services_stt_service_sttengine Community"
Cohesion: 0.33
Nodes (6): SttEngine, WhisperSttEngine, _FakeEngine, _FakeEngine, _FakeEngine, _FakeEngine

### Community 78 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

## Knowledge Gaps
- **1243 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+1238 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TranslatorViewModel` connect `lib_core_services_share_service_shareservice Community` to `appexception_get Community`, `test_integration_conversational_flow_test Community`, `fakepermissionapi Community`, `package_translatoo_ui_screens_history_screen_dart Community`, `icon Community`, `custompainter Community`, `lib_state_speech_view_model Community`, `lib_state_tts_view_model Community`, `core_services_flutter_tts_engine_dart Community`, `errorcode_get Community`, `lib_ui_screens_history_screen Community`, `core_services_app_exception_dart Community`, `changenotifier Community`, `completer Community`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `package_translatoo_core_services_mic_permission_service_dart Community`, `appexception_get Community`, `lib_core_services_app_exception Community`, `lib_core_services_cloud_translation_backend_cloudtranslationapi Community`, `package_flutter_test_flutter_test_dart Community`, `lib_core_services_share_service_shareservice Community`, `fakeaudio Community`, `package_translatoo_core_services_whisper_model_installer_dart Community`, `package_translatoo_core_services_translation_service_dart Community`, `test_integration_library_flow_test Community`, `fakeengine Community`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `Language` connect `lib_models_language Community` to `lib_models_app_settings Community`, `appexception_get Community`, `color Community`, `language_dart Community`, `lib_core_services_share_service_shareservice Community`, `lib_state_tts_view_model Community`, `datetime Community`, `lib_ui_widgets_language_bar Community`, `core_services_app_exception_dart Community`, `changenotifier Community`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _1243 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.022222222222222223 - nodes in this community are weakly interconnected._
- **Should `color Community` be split into smaller, more focused modules?**
  _Cohesion score 0.048265460030165915 - nodes in this community are weakly interconnected._
- **Should `appexception_get Community` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._