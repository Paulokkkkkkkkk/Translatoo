# Graph Report - .  (2026-09-02)

## Corpus Check
- 73 files · ~36,087 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1309 nodes · 1879 edges · 69 communities (68 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- level Community
- lib_core_services_stt_service_sttenginesession Community
- icon Community
- appexception_get Community
- lib_state_speech_view_model Community
- fakeaudio Community
- errorcode_get Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- core_services_app_exception_dart Community
- core_services_flutter_tts_engine_dart Community
- dart_math Community
- iconbutton Community
- appsettings_get Community
- double_get Community
- package_translatoo_state_tts_view_model_dart Community
- applifecyclelistener Community
- fakeengine Community
- package_translatoo_core_services_stt_service_dart Community
- lib_ui_widgets_language_bar Community
- completer Community
- lib_models_app_settings Community
- constants_app_colors_dart Community
- fluttertts Community
- core_constants_app_spacing_dart Community
- core_constants_app_strings_dart Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- datetime Community
- core_services_model_manager_service_dart Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- lib_state_speech_view_model_speechviewmodel Community
- package_translatoo_core_services_translation_backend_dart Community
- animation Community
- audiorecorder Community
- connectivityplatform Community
- constants_app_constants_dart Community
- dart_convert Community
- dart_typed_data Community
- future Community
- lib_core_constants_app_spacing Community
- lib_ui_widgets_translation_panel Community
- package_translatoo_core_services_app_exception_dart Community
- connectivity Community
- custompainter Community
- package_flutter_test_flutter_test_dart Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- package_translatoo_core_services_mic_permission_service_dart Community
- animationcontroller Community
- dart_io Community
- language_dart Community
- lib_core_services_app_exception Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
- bool_get Community
- color Community
- int_get Community
- lib_models_language Community
- lib_ui_widgets_language_bar_swapbutton Community
- app_exception_dart Community
- lib_core_services_flutter_tts_engine_flutterttsengine Community
- lib_core_services_tflite_translation_backend Community
- lib_ui_widgets_mini_player_tts Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_constants_app_strings_appstrings Community
- package_translatoo_core_constants_app_constants_dart Community
- exception Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 21 edges
2. `TtsViewModel` - 17 edges
3. `_` - 17 edges
4. `SpeechViewModel` - 15 edges
5. `ModelManagerService` - 14 edges
6. `TranslationBackend` - 11 edges
7. `AppException` - 10 edges
8. `Language` - 10 edges
9. `ModelManagerApi` - 9 edges
10. `SttAudioSource` - 7 edges

## Surprising Connections (you probably didn't know these)
- `_FakeApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/services/mic_permission_service_test.dart → lib/core/services/mic_permission_service.dart
- `_FakePermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/state/speech_view_model_test.dart → lib/core/services/mic_permission_service.dart
- `_GrantedPermissionApi` --implements--> `MicPermissionApi`  [EXTRACTED]
  test/widgets/mic_button_test.dart → lib/core/services/mic_permission_service.dart
- `_FakeApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/services/model_manager_service_test.dart → lib/core/services/model_manager_service.dart
- `_ReadyModelApi` --implements--> `ModelManagerApi`  [EXTRACTED]
  test/state/speech_view_model_test.dart → lib/core/services/model_manager_service.dart

## Import Cycles
- None detected.

## Communities (69 total, 1 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (67): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+59 more)

### Community 1 - "level Community"
Cohesion: 0.04
Nodes (48): Level, RecordAudioSource, amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose (+40 more)

### Community 2 - "lib_core_services_stt_service_sttenginesession Community"
Cohesion: 0.04
Nodes (47): SttEngineSession, _WhisperSession, Partial, _FakeSession, afterRequest, _amplitude, audio, backend (+39 more)

### Community 3 - "icon Community"
Cohesion: 0.05
Nodes (42): Icon, package:translatoo/ui/widgets/listening_sheet.dart, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, _amplitude, audio, _bytes, cancel (+34 more)

### Community 4 - "appexception_get Community"
Cohesion: 0.05
Nodes (40): AppException? get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, confirmDownloadAnyway, consumeDictatedFlag (+32 more)

### Community 5 - "lib_state_speech_view_model Community"
Cohesion: 0.05
Nodes (39): acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds, _elapsedTimer (+31 more)

### Community 6 - "fakeaudio Community"
Cohesion: 0.05
Nodes (37): _FakeAudio, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close, emit (+29 more)

### Community 7 - "errorcode_get Community"
Cohesion: 0.05
Nodes (36): ErrorCode? get, Language? get, acknowledgeError, _autoPlay, _clearError, dispose, _doubleTapWindow, _errorAction (+28 more)

### Community 8 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (35): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+27 more)

### Community 9 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (34): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+26 more)

### Community 10 - "core_services_app_exception_dart Community"
Cohesion: 0.08
Nodes (29): ../../core/services/app_exception.dart, TranslatorViewModel, _controller, _copyTranslation, createState, dispose, initState, _lastShownError (+21 more)

### Community 11 - "core_services_flutter_tts_engine_dart Community"
Cohesion: 0.08
Nodes (28): core/services/flutter_tts_engine.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, core/services/storage_service.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart (+20 more)

### Community 12 - "dart_math Community"
Cohesion: 0.07
Nodes (26): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+18 more)

### Community 13 - "iconbutton Community"
Cohesion: 0.07
Nodes (27): IconButton, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, amplitude, complete, configure, deleteModel (+19 more)

### Community 14 - "appsettings_get Community"
Cohesion: 0.08
Nodes (25): AppSettings get, Duration, dispose, _disposed, _favorites, flush, _flushing, _flushTimer (+17 more)

### Community 15 - "double_get Community"
Cohesion: 0.08
Nodes (25): double get, configure, dispose, _engine, _engineSub, ensureVoice, events, hashCode (+17 more)

### Community 16 - "package_translatoo_state_tts_view_model_dart Community"
Cohesion: 0.08
Nodes (25): package:translatoo/state/tts_view_model.dart, build, configure, deleteModel, dispose, downloadModel, emit, engine (+17 more)

### Community 17 - "applifecyclelistener Community"
Cohesion: 0.09
Nodes (23): AppLifecycleListener, ChangeNotifier, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, dispose (+15 more)

### Community 18 - "fakeengine Community"
Cohesion: 0.08
Nodes (23): _FakeEngine, package:translatoo/core/services/tts_service.dart, configure, configuredLanguages, dispose, emit, engine, errors (+15 more)

### Community 19 - "package_translatoo_core_services_stt_service_dart Community"
Cohesion: 0.08
Nodes (23): package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, RoundedRectangleBorder, ScaffoldState, amplitude, checkConnectivity, configure (+15 more)

### Community 20 - "lib_ui_widgets_language_bar Community"
Cohesion: 0.09
Nodes (22): build, createState, enabled, height, isTarget, language, leadingGap, onPressed (+14 more)

### Community 21 - "completer Community"
Cohesion: 0.09
Nodes (21): Completer, _EchoBackend, _FakeApi, package:translatoo/state/translator_view_model.dart, api, backend, build, deleteModel (+13 more)

### Community 22 - "lib_models_app_settings Community"
Cohesion: 0.10
Nodes (20): AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson, hashCode, kCurrentSchemaVersion (+12 more)

### Community 23 - "constants_app_colors_dart Community"
Cohesion: 0.12
Nodes (17): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppSemanticColors, AppTheme, _build, cjkFallback, copyWith (+9 more)

### Community 24 - "fluttertts Community"
Cohesion: 0.11
Nodes (17): FlutterTts, _active, _androidRate, configure, dispose, _events, _hasStarted, isLanguageAvailable (+9 more)

### Community 25 - "core_constants_app_spacing_dart Community"
Cohesion: 0.12
Nodes (14): ../../core/constants/app_spacing.dart, ../../core/theme/app_theme.dart, IconData, build, ConnectionBadge, isOnline, build, icon (+6 more)

### Community 26 - "core_constants_app_strings_dart Community"
Cohesion: 0.13
Nodes (15): ../../core/constants/app_strings.dart, build, HistoryScreen, _NavigationDrawer, build, SettingsScreen, _Half, LanguageBar (+7 more)

### Community 27 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 28 - "datetime Community"
Cohesion: 0.12
Nodes (15): DateTime?, copyWith, fromJson, hashCode, id, isFavorite, operator, sourceLang (+7 more)

### Community 29 - "core_services_model_manager_service_dart Community"
Cohesion: 0.19
Nodes (14): ../../core/services/model_manager_service.dart, ModelManagerService, TtsViewModel, build, DebugModelsScreen, language, _ModelTile, state (+6 more)

### Community 30 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 31 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 32 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.16
Nodes (15): SpeechViewModel, _onMicPressed, _OriginFooter, _showBlockedDialog, _, build, elapsed, _format (+7 more)

### Community 33 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.13
Nodes (14): package:translatoo/core/services/translation_backend.dart, package:translatoo/core/services/translation_service.dart, beginCapture, dispose, id, isModelDownloaded, isReady, main (+6 more)

### Community 34 - "animation Community"
Cohesion: 0.15
Nodes (13): Animation, animation, build, color, createState, dispose, maybe, MicButton (+5 more)

### Community 35 - "audiorecorder Community"
Cohesion: 0.14
Nodes (13): AudioRecorder, _amplitude, _amplitudeInterval, _amplitudeSub, dispose, _floorDb, _listenToAmplitude, normalize (+5 more)

### Community 36 - "connectivityplatform Community"
Cohesion: 0.14
Nodes (13): ConnectivityPlatform, package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart, package:translatoo/core/services/connectivity_service.dart, Stream, StreamController, checkConnectivity, _drainEventLoop, events (+5 more)

### Community 37 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 38 - "dart_convert Community"
Cohesion: 0.15
Nodes (12): dart:convert, package:fake_async/fake_async.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/translation_record.dart, main, _record, getInstance (+4 more)

### Community 39 - "dart_typed_data Community"
Cohesion: 0.14
Nodes (13): dart:typed_data, _controller, feed, _noAudio, partials, _session, startSession, stop (+5 more)

### Community 40 - "future Community"
Cohesion: 0.14
Nodes (13): Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation, modelsDirectory (+5 more)

### Community 41 - "lib_core_constants_app_spacing Community"
Cohesion: 0.14
Nodes (13): AppSpacing, lg, md, minTouchTarget, radius, radiusLg, radiusMd, radiusPill (+5 more)

### Community 42 - "lib_ui_widgets_translation_panel Community"
Cohesion: 0.14
Nodes (13): actions, build, child, expandChild, footer, header, languageLabel, onTapLanguage (+5 more)

### Community 43 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 44 - "connectivity Community"
Cohesion: 0.15
Nodes (12): Connectivity, dart:async, _apply, _connectivity, dispose, isOnline, isOnMobileData, start (+4 more)

### Community 45 - "custompainter Community"
Cohesion: 0.15
Nodes (12): CustomPainter, _barWidth, build, color, _gap, height, levels, paint (+4 more)

### Community 46 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.18
Nodes (9): package:flutter_test/flutter_test.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/language_pair.dart, main, main, main (+1 more)

### Community 47 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 48 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+3 more)

### Community 49 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 50 - "animationcontroller Community"
Cohesion: 0.18
Nodes (10): AnimationController, BorderRadius?, borderRadius, build, _controller, createState, dispose, height (+2 more)

### Community 51 - "dart_io Community"
Cohesion: 0.18
Nodes (8): dart:io, File, package:translatoo/core/constants/app_spacing.dart, package:translatoo/core/theme/app_theme.dart, main, main, main, stylesOf

### Community 52 - "language_dart Community"
Cohesion: 0.20
Nodes (9): language.dart, Language, hashCode, LanguagePair, operator, source, swapped, target (+1 more)

### Community 53 - "lib_core_services_app_exception Community"
Cohesion: 0.20
Nodes (9): cause, code, ErrorCode, stackTrace, SuggestedAction, toString, wireCode, Object? (+1 more)

### Community 54 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.20
Nodes (10): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _EchoBackend, _StubBackend (+2 more)

### Community 55 - "bool_get Community"
Cohesion: 0.22
Nodes (8): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart

### Community 56 - "color Community"
Cohesion: 0.22
Nodes (8): Color, ../../core/constants/app_constants.dart, build, DownloadProgressCard, language, onCancel, onDownload, state

### Community 57 - "int_get Community"
Cohesion: 0.31
Nodes (8): int get, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 58 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, mlKitCode, sttCode, tryFromCode, ttsCode, String get

### Community 59 - "lib_ui_widgets_language_bar_swapbutton Community"
Cohesion: 0.31
Nodes (9): _SwapButton, _SwapButtonState, MiniPlayerTts, _MiniPlayerTtsState, ShimmerBox, _ShimmerBoxState, SingleTickerProviderStateMixin, State (+1 more)

### Community 60 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, ../../models/language.dart

### Community 61 - "lib_core_services_flutter_tts_engine_flutterttsengine Community"
Cohesion: 0.29
Nodes (8): FlutterTtsEngine, TtsEngine, TtsEvent, _FakeEngine, _FakeTtsEngine, _SilentTtsEngine, _RecordingTtsEngine, _SilentTtsEngine

### Community 62 - "lib_core_services_tflite_translation_backend Community"
Cohesion: 0.25
Nodes (7): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart, translation_backend.dart

### Community 63 - "lib_ui_widgets_mini_player_tts Community"
Cohesion: 0.25
Nodes (7): build, createState, dispose, onStop, _pulse, text, VoidCallback

### Community 64 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.33
Nodes (6): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 65 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.40
Nodes (5): MicPermissionApi, PlatformMicPermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 66 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 67 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **913 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+908 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `language_dart Community` to `appexception_get Community`, `errorcode_get Community`, `core_services_app_exception_dart Community`, `lib_ui_widgets_language_bar Community`, `lib_models_app_settings Community`, `color Community`, `lib_models_language Community`, `datetime Community`, `core_services_model_manager_service_dart Community`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Why does `TranslatorViewModel` connect `core_services_app_exception_dart Community` to `lib_core_services_stt_service_sttenginesession Community`, `icon Community`, `appexception_get Community`, `lib_state_speech_view_model Community`, `errorcode_get Community`, `core_services_flutter_tts_engine_dart Community`, `package_translatoo_state_tts_view_model_dart Community`, `applifecyclelistener Community`, `completer Community`, `core_services_model_manager_service_dart Community`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `SpeechViewModel` connect `lib_state_speech_view_model_speechviewmodel Community` to `lib_core_services_stt_service_sttenginesession Community`, `animation Community`, `icon Community`, `lib_state_speech_view_model Community`, `core_services_app_exception_dart Community`, `iconbutton Community`, `applifecyclelistener Community`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _913 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.029411764705882353 - nodes in this community are weakly interconnected._
- **Should `level Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04251700680272109 - nodes in this community are weakly interconnected._
- **Should `lib_core_services_stt_service_sttenginesession Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04343971631205674 - nodes in this community are weakly interconnected._