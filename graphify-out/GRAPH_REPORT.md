# Graph Report - .  (2026-09-02)

## Corpus Check
- 86 files · ~46,327 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1584 nodes · 2376 edges · 77 communities (76 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- test_integration_conversational_flow_test Community
- lib_state_speech_view_model_speechviewmodel Community
- appexception_get Community
- fakepermissionapi Community
- icon Community
- lib_core_services_model_manager_service Community
- lib_state_speech_view_model Community
- fakeaudio Community
- lib_core_services_stt_service Community
- audiorecorder Community
- lib_core_constants_app_constants Community
- lib_state_tts_view_model Community
- dart_convert Community
- iconbutton Community
- errorcode_get Community
- dart_math Community
- core_services_flutter_tts_engine_dart Community
- fakettsengine Community
- core_constants_app_spacing_dart Community
- lib_ui_screens_history_screen Community
- appsettings_get Community
- lib_core_services_tts_service Community
- fakeengine Community
- package_translatoo_core_services_stt_service_dart Community
- applifecyclelistener Community
- duration Community
- lib_ui_widgets_language_bar Community
- dart_io Community
- completer Community
- lib_models_app_settings Community
- changenotifier Community
- package_translatoo_ui_screens_history_screen_dart Community
- core_services_app_exception_dart Community
- fluttertts Community
- package_translatoo_core_services_app_exception_dart Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- constants_app_colors_dart Community
- lib_ui_widgets_translation_panel Community
- dart_typed_data Community
- datetime Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- package_translatoo_core_constants_app_constants_dart Community
- color Community
- constants_app_constants_dart Community
- package_translatoo_core_services_translation_service_dart Community
- package_translatoo_state_library_view_model_dart Community
- connectivityplatform Community
- lib_core_constants_app_spacing Community
- package_provider_provider_dart Community
- animation Community
- connectivity Community
- exception Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- lib_core_services_translation_backend_translationbackend Community
- lib_ui_widgets_voice_block Community
- package_translatoo_core_services_mic_permission_service_dart Community
- language_dart Community
- lib_ui_widgets_language_bar_swapbutton Community
- borderradius Community
- animationcontroller Community
- bool_get Community
- core_constants_app_constants_dart Community
- int_get Community
- level Community
- lib_core_services_flutter_tts_engine_flutterttsengine Community
- lib_core_services_tflite_translation_backend Community
- lib_models_language Community
- app_exception_dart Community
- lib_ui_widgets_mode_button Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_services_stt_service_sttengine Community
- lib_core_constants_app_strings_appstrings Community
- lib_core_theme_app_theme_appsemanticcolors Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 27 edges
2. `TtsViewModel` - 22 edges
3. `ModelManagerService` - 20 edges
4. `SpeechViewModel` - 17 edges
5. `TranslationBackend` - 15 edges
6. `ModelManagerApi` - 14 edges
7. `Language` - 12 edges
8. `AppException` - 10 edges
9. `StorageService` - 10 edges
10. `SttAudioSource` - 8 edges

## Surprising Connections (you probably didn't know these)
- `_FakePermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/integration/conversational_flow_test.dart → lib/core/services/mic_permission_service.dart
- `_FakeApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/services/mic_permission_service_test.dart → lib/core/services/mic_permission_service.dart
- `_FakePermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/state/speech_view_model_test.dart → lib/core/services/mic_permission_service.dart
- `_GrantedPermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/widgets/mic_button_test.dart → lib/core/services/mic_permission_service.dart
- `_ReadyModelApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/integration/conversational_flow_test.dart → lib/core/services/model_manager_service.dart

## Import Cycles
- None detected.

## Communities (77 total, 1 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.02
Nodes (88): actionCancel, actionClear, actionClearAll, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway (+80 more)

### Community 1 - "test_integration_conversational_flow_test Community"
Cohesion: 0.04
Nodes (49): _amplitude, backend, build, _bytes, configure, configuredLanguages, current, deleteModel (+41 more)

### Community 2 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.06
Nodes (47): SpeechViewModel, TranslatorViewModel, TtsViewModel, build, _VoiceDebugPanel, HistoryScreen, _reopen, build (+39 more)

### Community 3 - "appexception_get Community"
Cohesion: 0.05
Nodes (42): AppException? get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, confirmDownloadAnyway, consumeDictatedFlag (+34 more)

### Community 4 - "fakepermissionapi Community"
Cohesion: 0.05
Nodes (42): _FakePermissionApi, afterRequest, _amplitude, audio, backend, build, _bytes, current (+34 more)

### Community 5 - "icon Community"
Cohesion: 0.05
Nodes (42): Icon, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, _amplitude, audio, _bytes, cancel, deleteModel (+34 more)

### Community 6 - "lib_core_services_model_manager_service Community"
Cohesion: 0.05
Nodes (40): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+32 more)

### Community 7 - "lib_state_speech_view_model Community"
Cohesion: 0.05
Nodes (39): acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds, _elapsedTimer (+31 more)

### Community 8 - "fakeaudio Community"
Cohesion: 0.05
Nodes (37): _FakeAudio, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close, emit (+29 more)

### Community 9 - "lib_core_services_stt_service Community"
Cohesion: 0.06
Nodes (35): amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose, _engine, _failSession (+27 more)

### Community 10 - "audiorecorder Community"
Cohesion: 0.06
Nodes (33): AudioRecorder, _amplitude, _amplitudeInterval, _amplitudeSub, dispose, _floorDb, _listenToAmplitude, normalize (+25 more)

### Community 11 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (34): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+26 more)

### Community 12 - "lib_state_tts_view_model Community"
Cohesion: 0.06
Nodes (33): acknowledgeError, _autoPlay, _clearError, dispose, _doubleTapWindow, _errorAction, _errorCode, _errorLanguage (+25 more)

### Community 13 - "dart_convert Community"
Cohesion: 0.09
Nodes (25): dart:convert, Map, package:fake_async/fake_async.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/translation_record.dart (+17 more)

### Community 14 - "iconbutton Community"
Cohesion: 0.07
Nodes (29): IconButton, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, package:translatoo/ui/widgets/mode_button.dart, package:translatoo/ui/widgets/voice_block.dart, amplitude, complete (+21 more)

### Community 15 - "errorcode_get Community"
Cohesion: 0.07
Nodes (28): ErrorCode? get, acknowledgeError, addRecord, canUndo, clearHistory, delete, dispose, _enforceLimit (+20 more)

### Community 16 - "dart_math Community"
Cohesion: 0.07
Nodes (26): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+18 more)

### Community 17 - "core_services_flutter_tts_engine_dart Community"
Cohesion: 0.09
Nodes (26): core/services/flutter_tts_engine.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart, ../core/services/tts_service.dart (+18 more)

### Community 18 - "fakettsengine Community"
Cohesion: 0.07
Nodes (26): _FakeTtsEngine, package:translatoo/state/tts_view_model.dart, build, configure, deleteModel, dispose, downloadModel, emit (+18 more)

### Community 19 - "core_constants_app_spacing_dart Community"
Cohesion: 0.09
Nodes (22): ../../core/constants/app_spacing.dart, ../../core/constants/app_strings.dart, ../../core/theme/app_theme.dart, IconData, TranslationRecord, build, ConnectionBadge, isOnline (+14 more)

### Community 20 - "lib_ui_screens_history_screen Community"
Cohesion: 0.09
Nodes (25): build, _Chip, _confirmClearAll, _DeleteBackground, _deleteWithUndo, _FilterChips, label, onChanged (+17 more)

### Community 21 - "appsettings_get Community"
Cohesion: 0.08
Nodes (24): AppSettings get, ../core/services/storage_service.dart, double get, Language? get, autoPlay, setAutoPlay, setSourceLanguage, setTargetLanguage (+16 more)

### Community 22 - "lib_core_services_tts_service Community"
Cohesion: 0.08
Nodes (24): configure, dispose, _engine, _engineSub, ensureVoice, events, hashCode, isLanguageAvailable (+16 more)

### Community 23 - "fakeengine Community"
Cohesion: 0.08
Nodes (23): _FakeEngine, package:translatoo/core/services/tts_service.dart, configure, configuredLanguages, dispose, emit, engine, errors (+15 more)

### Community 24 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.08
Nodes (23): package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, RoundedRectangleBorder, ScaffoldState, amplitude, checkConnectivity, configure (+15 more)

### Community 25 - "applifecyclelistener Community"
Cohesion: 0.10
Nodes (22): AppLifecycleListener, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, dispose, HomeScreen (+14 more)

### Community 26 - "duration Community"
Cohesion: 0.09
Nodes (22): Duration, dispose, _disposed, _favorites, flush, _flushing, _flushTimer, _history (+14 more)

### Community 27 - "lib_ui_widgets_language_bar Community"
Cohesion: 0.09
Nodes (22): build, createState, enabled, height, isTarget, language, leadingGap, onPressed (+14 more)

### Community 28 - "dart_io Community"
Cohesion: 0.10
Nodes (16): dart:io, File, package:flutter_test/flutter_test.dart, package:translatoo/core/constants/app_spacing.dart, package:translatoo/core/constants/app_strings.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/core/theme/app_theme.dart, package:translatoo/ui/widgets/connection_badge.dart (+8 more)

### Community 29 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 30 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 31 - "changenotifier Community"
Cohesion: 0.12
Nodes (19): ChangeNotifier, LibraryViewModel, SettingsViewModel, appVersion, _confirmClearHistory, label, _LanguageTile, max (+11 more)

### Community 32 - "package_translatoo_ui_screens_history_screen_dart Community"
Cohesion: 0.10
Nodes (19): package:translatoo/ui/screens/history_screen.dart, package:translatoo/ui/widgets/history_card.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady (+11 more)

### Community 33 - "core_services_app_exception_dart Community"
Cohesion: 0.15
Nodes (17): ../../core/services/app_exception.dart, ../../core/services/model_manager_service.dart, dart:async, ModelManagerService, DebugModelsScreen, language, _ModelTile, state (+9 more)

### Community 34 - "fluttertts Community"
Cohesion: 0.11
Nodes (18): FlutterTts, _active, _androidRate, configure, dispose, _events, _hasStarted, isLanguageAvailable (+10 more)

### Community 35 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.12
Nodes (15): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/translation_backend.dart, main, beginCapture, dispose, id, isModelDownloaded, isReady (+7 more)

### Community 36 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 37 - "constants_app_colors_dart Community"
Cohesion: 0.12
Nodes (15): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppTheme, _build, cjkFallback, copyWith, dark (+7 more)

### Community 38 - "lib_ui_widgets_translation_panel Community"
Cohesion: 0.12
Nodes (15): actions, build, child, expandChild, footer, header, languageLabel, onTapLanguage (+7 more)

### Community 39 - "dart_typed_data Community"
Cohesion: 0.13
Nodes (14): dart:typed_data, Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation (+6 more)

### Community 40 - "datetime Community"
Cohesion: 0.13
Nodes (14): DateTime?, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+6 more)

### Community 41 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 42 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 43 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.13
Nodes (13): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/core/services/text_chunker.dart, package:translatoo/models/model_state.dart, completeDownload, deleteModel, downloadModel, failDownload (+5 more)

### Community 44 - "color Community"
Cohesion: 0.14
Nodes (13): Color?, CustomPainter, _barWidth, build, color, _gap, height, levels (+5 more)

### Community 45 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 46 - "package_translatoo_core_services_translation_service_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/translation_service.dart, package:translatoo/models/language_pair.dart, package:translatoo/state/translator_view_model.dart, main, deleteModel, dispose, downloadModel, id (+4 more)

### Community 47 - "package_translatoo_state_library_view_model_dart Community"
Cohesion: 0.14
Nodes (13): package:translatoo/state/library_view_model.dart, deleteModel, dispose, downloadModel, id, isModelDownloaded, isReady, main (+5 more)

### Community 48 - "connectivityplatform Community"
Cohesion: 0.15
Nodes (12): ConnectivityPlatform, List, package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/services/connectivity_service.dart, checkConnectivity, _drainEventLoop, events, _FakePlatform (+4 more)

### Community 49 - "lib_core_constants_app_spacing Community"
Cohesion: 0.15
Nodes (12): AppSpacing, lg, md, minTouchTarget, radius, radiusLg, radiusMd, radiusPill (+4 more)

### Community 50 - "package_provider_provider_dart Community"
Cohesion: 0.15
Nodes (12): package:provider/provider.dart, package:translatoo/ui/screens/model_manager_screen.dart, complete, deleteModel, downloadModel, installed, isModelDownloaded, main (+4 more)

### Community 51 - "animation Community"
Cohesion: 0.17
Nodes (11): Animation, animation, build, color, createState, dispose, maybe, onPressed (+3 more)

### Community 52 - "connectivity Community"
Cohesion: 0.17
Nodes (11): Connectivity, _apply, _connectivity, dispose, isOnline, isOnMobileData, start, _subscription (+3 more)

### Community 53 - "exception Community"
Cohesion: 0.17
Nodes (11): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+3 more)

### Community 54 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 55 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, MlKitTranslationBackend, _toPlugin, translate (+3 more)

### Community 56 - "lib_core_services_translation_backend_translationbackend Community"
Cohesion: 0.17
Nodes (12): TranslationBackend, _EchoBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _EchoBackend, _EchoBackend, _EchoBackend (+4 more)

### Community 57 - "lib_ui_widgets_voice_block Community"
Cohesion: 0.17
Nodes (11): color, height, _IdleHint, label, listening, _mmss, _start, VoiceBlock (+3 more)

### Community 58 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 59 - "language_dart Community"
Cohesion: 0.18
Nodes (10): language.dart, Language, hashCode, LanguagePair, operator, source, swapped, target (+2 more)

### Community 60 - "lib_ui_widgets_language_bar_swapbutton Community"
Cohesion: 0.27
Nodes (11): _SwapButton, _SwapButtonState, MicButton, _MicButtonState, MiniPlayerTts, _MiniPlayerTtsState, ShimmerBox, _ShimmerBoxState (+3 more)

### Community 61 - "borderradius Community"
Cohesion: 0.20
Nodes (9): BorderRadius?, borderRadius, build, _controller, createState, dispose, height, lines (+1 more)

### Community 62 - "animationcontroller Community"
Cohesion: 0.22
Nodes (8): AnimationController, build, createState, dispose, onStop, _pulse, text, VoidCallback

### Community 63 - "bool_get Community"
Cohesion: 0.22
Nodes (8): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart

### Community 64 - "core_constants_app_constants_dart Community"
Cohesion: 0.22
Nodes (8): ../../core/constants/app_constants.dart, build, DownloadProgressCard, language, onCancel, onDownload, state, ../../models/model_state.dart

### Community 65 - "int_get Community"
Cohesion: 0.31
Nodes (8): int get, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 66 - "level Community"
Cohesion: 0.28
Nodes (9): Level, RecordAudioSource, SttAudioSource, _FakeAudio, _FakeAudio, _FakeAudio, _SilentAudio, _FakeAudio (+1 more)

### Community 67 - "lib_core_services_flutter_tts_engine_flutterttsengine Community"
Cohesion: 0.25
Nodes (9): FlutterTtsEngine, TtsEngine, TtsEvent, _FakeTtsEngine, _FakeEngine, _FakeTtsEngine, _SilentTtsEngine, _RecordingTtsEngine (+1 more)

### Community 68 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.22
Nodes (8): dispose, id, isModelDownloaded, isReady, TfliteTranslationBackend, translate, ../../models/language_pair.dart, translation_backend.dart

### Community 69 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, mlKitCode, sttCode, tryFromCode, ttsCode, String get

### Community 70 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, ../../models/language.dart

### Community 71 - "lib_ui_widgets_mode_button Community"
Cohesion: 0.25
Nodes (7): build, mode, ModeButton, onToggle, size, TranslateMode, static const double

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
- **1118 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+1113 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `language_dart Community` to `core_constants_app_constants_dart Community`, `core_services_app_exception_dart Community`, `lib_state_speech_view_model_speechviewmodel Community`, `appexception_get Community`, `lib_models_language Community`, `datetime Community`, `lib_state_tts_view_model Community`, `lib_ui_widgets_language_bar Community`, `lib_models_app_settings Community`, `changenotifier Community`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `TranslatorViewModel` connect `lib_state_speech_view_model_speechviewmodel Community` to `package_translatoo_ui_screens_history_screen_dart Community`, `test_integration_conversational_flow_test Community`, `appexception_get Community`, `fakepermissionapi Community`, `icon Community`, `lib_state_speech_view_model Community`, `lib_state_tts_view_model Community`, `errorcode_get Community`, `core_services_flutter_tts_engine_dart Community`, `fakettsengine Community`, `lib_ui_screens_history_screen Community`, `completer Community`, `changenotifier Community`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Why does `ModelManagerService` connect `core_services_app_exception_dart Community` to `package_translatoo_ui_screens_history_screen_dart Community`, `test_integration_conversational_flow_test Community`, `lib_state_speech_view_model_speechviewmodel Community`, `appexception_get Community`, `fakepermissionapi Community`, `icon Community`, `lib_core_services_model_manager_service Community`, `core_services_flutter_tts_engine_dart Community`, `fakettsengine Community`, `completer Community`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _1118 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.02247191011235955 - nodes in this community are weakly interconnected._
- **Should `test_integration_conversational_flow_test Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `lib_state_speech_view_model_speechviewmodel Community` be split into smaller, more focused modules?**
  _Cohesion score 0.06028368794326241 - nodes in this community are weakly interconnected._