# Graph Report - .  (2026-09-03)

## Corpus Check
- 100 files · ~54,853 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1762 nodes · 2682 edges · 90 communities (89 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- appexception_get Community
- test_integration_conversational_flow_test Community
- fakepermissionapi Community
- icon Community
- lib_core_services_share_service_shareservice Community
- lib_state_speech_view_model Community
- fakeaudio Community
- lib_core_services_stt_service Community
- dart_io Community
- lib_state_tts_view_model Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- iconbutton Community
- core_services_flutter_tts_engine_dart Community
- custompainter Community
- errorcode_get Community
- package_shared_preferences_shared_preferences_dart Community
- dart_math Community
- fakettsengine Community
- core_constants_app_spacing_dart Community
- lib_ui_screens_history_screen Community
- lib_core_services_tts_service Community
- core_services_storage_service_dart Community
- appsettings_get Community
- core_services_app_exception_dart Community
- fakeengine Community
- lib_ui_widgets_language_bar Community
- completer Community
- roundedrectangleborder Community
- lib_core_services_pinyin_service Community
- lib_core_services_translation_service Community
- lib_models_app_settings Community
- package_translatoo_ui_screens_history_screen_dart Community
- applifecyclelistener Community
- lib_state_library_view_model_libraryviewmodel Community
- constants_app_colors_dart Community
- lib_core_services_cloud_translation_backend_cloudtranslationapi Community
- lib_state_speech_view_model_speechviewmodel Community
- test_widgets_responsive_doubles Community
- lib_core_services_tflite_translation_backend Community
- package_translatoo_core_services_app_exception_dart Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- dart_convert Community
- test_state_warm_up_test Community
- dart_typed_data Community
- datetime Community
- exception Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_backend_translationbackend Community
- test_integration_library_flow_test Community
- audiorecorder Community
- lib_core_services_whisper_stt_engine Community
- test_state_library_view_model_test Community
- animation Community
- connectivity Community
- lib_core_constants_app_spacing Community
- lib_core_services_text_chunker Community
- package_translatoo_core_services_stt_service_dart Community
- package_translatoo_ui_screens_model_manager_screen_dart Community
- bool_get Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- package_translatoo_core_services_mic_permission_service_dart Community
- package_translatoo_core_services_translation_service_dart Community
- constants_app_constants_dart Community
- lib_ui_widgets_language_bar_swapbutton Community
- package_translatoo_core_services_share_service_dart Community
- borderradius Community
- color Community
- level Community
- lib_core_services_app_exception Community
- lib_core_services_flutter_tts_engine_flutterttsengine Community
- lib_core_utils_perf_trace Community
- package_connectivity_plus_platform_interface_connectivity_plus_platform_interface_dart Community
- app_exception_dart Community
- int Community
- int_get Community
- lib_models_language Community
- lib_ui_widgets_mode_button Community
- package_flutter_test_flutter_test_dart Community
- animationcontroller Community
- lib_core_services_stt_service_sttenginesession Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- changenotifier Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_services_stt_service_sttengine Community
- connectivityplatform Community
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
- `_StubApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/integration/library_flow_test.dart → lib/core/services/model_manager_service.dart
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/services/model_manager_service_test.dart → lib/core/services/model_manager_service.dart
- `_ReadyModelApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/library_view_model_test.dart → lib/core/services/model_manager_service.dart
- `_ReadyApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/translator_persistence_test.dart → lib/core/services/model_manager_service.dart
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/translator_view_model_test.dart → lib/core/services/model_manager_service.dart

## Import Cycles
- None detected.

## Communities (90 total, 1 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.02
Nodes (89): actionCancel, actionClear, actionClearAll, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway (+81 more)

### Community 1 - "appexception_get Community"
Cohesion: 0.04
Nodes (51): AppException? get, ../core/services/pinyin_service.dart, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, _clearStaleResult (+43 more)

### Community 2 - "test_integration_conversational_flow_test Community"
Cohesion: 0.04
Nodes (49): _amplitude, backend, build, _bytes, configure, configuredLanguages, current, deleteModel (+41 more)

### Community 3 - "fakepermissionapi Community"
Cohesion: 0.05
Nodes (42): _FakePermissionApi, afterRequest, _amplitude, audio, backend, build, _bytes, current (+34 more)

### Community 4 - "icon Community"
Cohesion: 0.05
Nodes (42): Icon, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, _amplitude, audio, _bytes, cancel, deleteModel (+34 more)

### Community 5 - "lib_core_services_share_service_shareservice Community"
Cohesion: 0.07
Nodes (39): ShareService, TranslatorViewModel, HistoryScreen, _reopen, _controller, _copyTranslation, createState, _DestinationPanel (+31 more)

### Community 6 - "lib_state_speech_view_model Community"
Cohesion: 0.05
Nodes (39): acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds, _elapsedTimer (+31 more)

### Community 7 - "fakeaudio Community"
Cohesion: 0.05
Nodes (37): _FakeAudio, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close, emit (+29 more)

### Community 8 - "lib_core_services_stt_service Community"
Cohesion: 0.05
Nodes (36): amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose, _engine, _failSession (+28 more)

### Community 9 - "dart_io Community"
Cohesion: 0.06
Nodes (30): dart:io, File, FlutterTts, _active, _androidRate, configure, dispose, _events (+22 more)

### Community 10 - "lib_state_tts_view_model Community"
Cohesion: 0.06
Nodes (33): acknowledgeError, _autoPlay, _clearError, dispose, _doubleTapWindow, _errorAction, _errorCode, _errorLanguage (+25 more)

### Community 11 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (32): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+24 more)

### Community 12 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (31): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+23 more)

### Community 13 - "iconbutton Community"
Cohesion: 0.06
Nodes (30): IconButton, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/widgets/download_progress_card.dart, package:translatoo/ui/widgets/mode_button.dart, package:translatoo/ui/widgets/voice_block.dart, ReadingOrderTraversalPolicy, amplitude, complete (+22 more)

### Community 14 - "core_services_flutter_tts_engine_dart Community"
Cohesion: 0.08
Nodes (29): core/services/flutter_tts_engine.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, ../../core/services/share_service.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart (+21 more)

### Community 15 - "custompainter Community"
Cohesion: 0.07
Nodes (27): CustomPainter, actions, build, child, expandChild, footer, header, languageLabel (+19 more)

### Community 16 - "errorcode_get Community"
Cohesion: 0.07
Nodes (28): ErrorCode? get, acknowledgeError, addRecord, canUndo, clearHistory, delete, dispose, _enforceLimit (+20 more)

### Community 17 - "package_shared_preferences_shared_preferences_dart Community"
Cohesion: 0.09
Nodes (24): package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/state/library_view_model.dart, package:translatoo/state/settings_view_model.dart, package:translatoo/ui/screens/settings_screen.dart, main (+16 more)

### Community 18 - "dart_math Community"
Cohesion: 0.07
Nodes (26): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+18 more)

### Community 19 - "fakettsengine Community"
Cohesion: 0.07
Nodes (27): _FakeTtsEngine, package:translatoo/state/tts_view_model.dart, build, configure, deleteModel, dispose, downloadModel, emit (+19 more)

### Community 20 - "core_constants_app_spacing_dart Community"
Cohesion: 0.09
Nodes (22): ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, ../../core/theme/app_theme.dart, IconData, TranslationRecord, build, ConnectionBadge, isOnline (+14 more)

### Community 21 - "lib_ui_screens_history_screen Community"
Cohesion: 0.09
Nodes (25): build, _Chip, _confirmClearAll, _DeleteBackground, _deleteWithUndo, _FilterChips, label, onChanged (+17 more)

### Community 22 - "lib_core_services_tts_service Community"
Cohesion: 0.08
Nodes (24): configure, dispose, _engine, _engineSub, ensureVoice, events, hashCode, isLanguageAvailable (+16 more)

### Community 23 - "core_services_storage_service_dart Community"
Cohesion: 0.08
Nodes (23): ../core/services/storage_service.dart, double get, Language? get, autoPlay, setAutoPlay, setSourceLanguage, setTargetLanguage, setThemeMode (+15 more)

### Community 24 - "appsettings_get Community"
Cohesion: 0.09
Nodes (22): AppSettings get, dispose, _disposed, _favorites, flush, _flushing, _flushTimer, _history (+14 more)

### Community 25 - "core_services_app_exception_dart Community"
Cohesion: 0.13
Nodes (21): ../../core/services/app_exception.dart, ../../core/services/model_manager_service.dart, ModelManagerService, TtsViewModel, build, DebugModelsScreen, language, _ModelTile (+13 more)

### Community 26 - "fakeengine Community"
Cohesion: 0.09
Nodes (22): _FakeEngine, configure, configuredLanguages, dispose, emit, engine, errors, _events (+14 more)

### Community 27 - "lib_ui_widgets_language_bar Community"
Cohesion: 0.09
Nodes (22): build, createState, enabled, height, isTarget, language, leadingGap, onPressed (+14 more)

### Community 28 - "completer Community"
Cohesion: 0.09
Nodes (21): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+13 more)

### Community 29 - "roundedrectangleborder Community"
Cohesion: 0.09
Nodes (21): RoundedRectangleBorder, ScaffoldState, amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel (+13 more)

### Community 30 - "lib_core_services_pinyin_service Community"
Cohesion: 0.10
Nodes (19): _doubleSpace, engine, _han, PackagePinyinEngine, PinyinEngine, PinyinService, romanize, romanizeFor (+11 more)

### Community 31 - "lib_core_services_translation_service Community"
Cohesion: 0.10
Nodes (20): activeBackend, _cloud, cloudActive, dispose, _fallback, _fallbackEnabled, isReady, lastResultWasLocal (+12 more)

### Community 32 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 33 - "package_translatoo_ui_screens_history_screen_dart Community"
Cohesion: 0.10
Nodes (20): package:translatoo/ui/screens/history_screen.dart, package:translatoo/ui/widgets/history_card.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady (+12 more)

### Community 34 - "applifecyclelistener Community"
Cohesion: 0.11
Nodes (18): AppLifecycleListener, debug_models_screen.dart, history_screen.dart, createState, dispose, HomeScreen, _HomeScreenState, _index (+10 more)

### Community 35 - "lib_state_library_view_model_libraryviewmodel Community"
Cohesion: 0.12
Nodes (18): LibraryViewModel, appVersion, _confirmClearHistory, label, max, min, onChanged, onSelected (+10 more)

### Community 36 - "constants_app_colors_dart Community"
Cohesion: 0.12
Nodes (17): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppSemanticColors, AppTheme, _build, cjkFallback, copyWith (+9 more)

### Community 37 - "lib_core_services_cloud_translation_backend_cloudtranslationapi Community"
Cohesion: 0.12
Nodes (17): CloudTranslationApi, package:translatoo/core/services/cloud_translation_backend.dart, api, build, calls, delay, dispose, error (+9 more)

### Community 38 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.12
Nodes (17): SpeechViewModel, _onMicPressed, _OriginFooter, _showBlockedDialog, _toggleMode, build, color, height (+9 more)

### Community 39 - "test_widgets_responsive_doubles Community"
Cohesion: 0.11
Nodes (17): amplitude, checkConnectivity, configure, deleteModel, dispose, downloadModel, _events, id (+9 more)

### Community 40 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.13
Nodes (15): dispose, id, isModelDownloaded, isReady, TfliteTranslationBackend, translate, dispose, id (+7 more)

### Community 41 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.12
Nodes (15): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/translation_backend.dart, main, beginCapture, dispose, id, isModelDownloaded, isReady (+7 more)

### Community 42 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 43 - "dart_convert Community"
Cohesion: 0.13
Nodes (13): dart:convert, Map, package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, package:translatoo/models/translation_record.dart, main, _record, getInstance (+5 more)

### Community 44 - "test_state_warm_up_test Community"
Cohesion: 0.12
Nodes (15): backend, _CountingBackend, deleteModel, dispose, downloadModel, error, id, installed (+7 more)

### Community 45 - "dart_typed_data Community"
Cohesion: 0.13
Nodes (14): dart:typed_data, Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation (+6 more)

### Community 46 - "datetime Community"
Cohesion: 0.13
Nodes (14): DateTime?, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+6 more)

### Community 47 - "exception Community"
Cohesion: 0.13
Nodes (14): Exception, AppException, package:fake_async/fake_async.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, completeDownload, deleteModel, downloadModel (+6 more)

### Community 48 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 49 - "lib_core_services_translation_backend_translationbackend Community"
Cohesion: 0.13
Nodes (15): TranslationBackend, _EchoBackend, _EchoBackend, _LocalBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _EchoBackend (+7 more)

### Community 50 - "test_integration_library_flow_test Community"
Cohesion: 0.13
Nodes (14): deleteModel, dispose, downloadCalls, downloadModel, id, installed, isModelDownloaded, isReady (+6 more)

### Community 51 - "audiorecorder Community"
Cohesion: 0.14
Nodes (13): AudioRecorder, _amplitude, _amplitudeInterval, _amplitudeSub, dispose, _floorDb, _listenToAmplitude, normalize (+5 more)

### Community 52 - "lib_core_services_whisper_stt_engine Community"
Cohesion: 0.14
Nodes (13): _controller, feed, _noAudio, partials, _session, startSession, stop, package:whisper_ggml/whisper_ggml.dart (+5 more)

### Community 53 - "test_state_library_view_model_test Community"
Cohesion: 0.14
Nodes (13): deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady, main, _ReadyModelApi (+5 more)

### Community 54 - "animation Community"
Cohesion: 0.15
Nodes (12): Animation, animation, build, color, createState, dispose, maybe, onPressed (+4 more)

### Community 55 - "connectivity Community"
Cohesion: 0.15
Nodes (12): Connectivity, dart:async, _apply, _connectivity, dispose, isOnline, isOnMobileData, start (+4 more)

### Community 56 - "lib_core_constants_app_spacing Community"
Cohesion: 0.15
Nodes (12): AppSpacing, lg, md, minTouchTarget, radius, radiusLg, radiusMd, radiusPill (+4 more)

### Community 57 - "lib_core_services_text_chunker Community"
Cohesion: 0.15
Nodes (12): _breakUnits, chunks, chunkText, _findCutIndex, high, index, low, max (+4 more)

### Community 58 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.15
Nodes (12): package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/tts_service.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, package:translatoo/ui/screens/translate_screen.dart, responsive_doubles.dart, Scaffold, connectivity (+4 more)

### Community 59 - "package_translatoo_ui_screens_model_manager_screen_dart Community"
Cohesion: 0.15
Nodes (12): package:translatoo/ui/screens/model_manager_screen.dart, complete, deleteModel, downloadModel, _GateApi, installed, isModelDownloaded, main (+4 more)

### Community 60 - "bool_get Community"
Cohesion: 0.17
Nodes (10): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart (+2 more)

### Community 61 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 62 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, MlKitTranslationBackend, _toPlugin, translate (+3 more)

### Community 63 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 64 - "package_translatoo_core_services_translation_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/translation_service.dart, package:translatoo/state/translator_view_model.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady (+3 more)

### Community 65 - "constants_app_constants_dart Community"
Cohesion: 0.18
Nodes (10): ../constants/app_constants.dart, Duration, _api, CloudTranslationBackend, dispose, id, isModelDownloaded, isReady (+2 more)

### Community 66 - "lib_ui_widgets_language_bar_swapbutton Community"
Cohesion: 0.27
Nodes (11): _SwapButton, _SwapButtonState, MicButton, _MicButtonState, MiniPlayerTts, _MiniPlayerTtsState, ShimmerBox, _ShimmerBoxState (+3 more)

### Community 67 - "package_translatoo_core_services_share_service_dart Community"
Cohesion: 0.18
Nodes (10): package:translatoo/core/services/share_service.dart, String?, calls, error, main, platform, service, shareText (+2 more)

### Community 68 - "borderradius Community"
Cohesion: 0.20
Nodes (9): BorderRadius?, borderRadius, build, _controller, createState, dispose, height, lines (+1 more)

### Community 69 - "color Community"
Cohesion: 0.20
Nodes (9): Color?, ../../core/constants/app_constants.dart, build, DownloadProgressCard, language, onCancel, onDownload, state (+1 more)

### Community 70 - "level Community"
Cohesion: 0.24
Nodes (10): Level, RecordAudioSource, SttAudioSource, _FakeAudio, _FakeAudio, _FakeAudio, _SilentAudio, _FakeAudio (+2 more)

### Community 71 - "lib_core_services_app_exception Community"
Cohesion: 0.20
Nodes (9): cause, code, ErrorCode, stackTrace, SuggestedAction, toString, wireCode, Object? (+1 more)

### Community 72 - "lib_core_services_flutter_tts_engine_flutterttsengine Community"
Cohesion: 0.22
Nodes (10): FlutterTtsEngine, TtsEngine, TtsEvent, _FakeTtsEngine, _FakeEngine, _FakeTtsEngine, _SilentTtsEngine, SilentTtsEngine (+2 more)

### Community 73 - "lib_core_utils_perf_trace Community"
Cohesion: 0.20
Nodes (9): budget, budgetMs, label, PerfBudget, PerfTrace, start, stop, _watch (+1 more)

### Community 74 - "package_connectivity_plus_platform_interface_connectivity_plus_platform_interface_dart Community"
Cohesion: 0.20
Nodes (9): package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/services/connectivity_service.dart, StreamController, checkConnectivity, _drainEventLoop, events, initialResults, main (+1 more)

### Community 75 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (8): app_exception.dart, _platform, PlatformShare, SharePlatform, shareText, shareTranslation, package:share_plus/share_plus.dart, _FakeShare

### Community 76 - "int Community"
Cohesion: 0.31
Nodes (8): int?, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 77 - "int_get Community"
Cohesion: 0.22
Nodes (8): int get, language.dart, hashCode, operator, source, swapped, target, toString

### Community 78 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, Language, mlKitCode, sttCode, tryFromCode, ttsCode

### Community 79 - "lib_ui_widgets_mode_button Community"
Cohesion: 0.22
Nodes (8): build, mode, ModeButton, onToggle, size, TranslateMode, static const double, VoidCallback

### Community 80 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.22
Nodes (6): package:flutter_test/flutter_test.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/models/language_pair.dart, main, main, main

### Community 81 - "animationcontroller Community"
Cohesion: 0.25
Nodes (7): AnimationController, build, createState, dispose, onStop, _pulse, text

### Community 82 - "lib_core_services_stt_service_sttenginesession Community"
Cohesion: 0.43
Nodes (7): SttEngineSession, _WhisperSession, Partial, _FakeSession, _FakeSession, _FakeSession, _FakeSession

### Community 83 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.29
Nodes (7): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 84 - "changenotifier Community"
Cohesion: 0.33
Nodes (6): ChangeNotifier, ConnectionViewModel, SettingsViewModel, build, build, MaterialPageRoute

### Community 85 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.33
Nodes (6): MicPermissionApi, PlatformMicPermissionApi, _FakePermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 86 - "lib_core_services_stt_service_sttengine Community"
Cohesion: 0.33
Nodes (6): SttEngine, WhisperSttEngine, _FakeEngine, _FakeEngine, _FakeEngine, _FakeEngine

### Community 87 - "connectivityplatform Community"
Cohesion: 0.50
Nodes (4): ConnectivityPlatform, _FakePlatform, _FakePlatform, FakeConnectivity

### Community 88 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

## Knowledge Gaps
- **1241 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+1236 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TranslatorViewModel` connect `lib_core_services_share_service_shareservice Community` to `appexception_get Community`, `test_integration_conversational_flow_test Community`, `fakepermissionapi Community`, `package_translatoo_ui_screens_history_screen_dart Community`, `icon Community`, `lib_state_speech_view_model Community`, `lib_state_tts_view_model Community`, `core_services_flutter_tts_engine_dart Community`, `errorcode_get Community`, `fakettsengine Community`, `changenotifier Community`, `lib_ui_screens_history_screen Community`, `core_services_app_exception_dart Community`, `completer Community`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `appexception_get Community`, `package_translatoo_core_services_share_service_dart Community`, `lib_core_services_cloud_translation_backend_cloudtranslationapi Community`, `lib_core_services_share_service_shareservice Community`, `lib_core_services_app_exception Community`, `fakeaudio Community`, `package_translatoo_core_services_app_exception_dart Community`, `package_translatoo_core_services_whisper_model_installer_dart Community`, `test_integration_library_flow_test Community`, `fakeengine Community`, `package_translatoo_core_services_mic_permission_service_dart Community`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `Language` connect `lib_models_language Community` to `lib_models_app_settings Community`, `appexception_get Community`, `lib_state_library_view_model_libraryviewmodel Community`, `lib_core_services_share_service_shareservice Community`, `color Community`, `lib_state_tts_view_model Community`, `int_get Community`, `datetime Community`, `core_services_app_exception_dart Community`, `lib_ui_widgets_language_bar Community`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _1241 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.022222222222222223 - nodes in this community are weakly interconnected._
- **Should `appexception_get Community` be split into smaller, more focused modules?**
  _Cohesion score 0.038461538461538464 - nodes in this community are weakly interconnected._
- **Should `test_integration_conversational_flow_test Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._