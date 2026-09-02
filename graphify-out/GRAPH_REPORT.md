# Graph Report - .  (2026-09-02)

## Corpus Check
- 66 files · ~28,034 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1091 nodes · 1533 edges · 50 communities (49 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- connectivityplatform Community
- icon Community
- level Community
- bool_get Community
- datetime Community
- errorcode_get Community
- test_state_speech_view_model_test Community
- audiorecorder Community
- appexception_get Community
- fakeaudio Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- applifecyclelistener Community
- appsettings_get Community
- constants_app_colors_dart Community
- dart_math Community
- color Community
- package_translatoo_core_services_whisper_stt_engine_dart Community
- animation Community
- completer Community
- package_translatoo_core_services_whisper_model_installer_dart Community
- lib_state_speech_view_model_speechviewmodel Community
- lib_core_services_translation_service Community
- package_translatoo_core_services_translation_backend_dart Community
- constants_app_constants_dart Community
- dart_convert Community
- future Community
- package_translatoo_core_services_app_exception_dart Community
- package_flutter_test_flutter_test_dart Community
- core_constants_app_spacing_dart Community
- core_constants_app_strings_dart Community
- exception Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- package_translatoo_core_services_mic_permission_service_dart Community
- animationcontroller Community
- core_services_model_manager_service_dart Community
- core_constants_app_constants_dart Community
- int_get Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
- lib_models_language Community
- lib_ui_widgets_language_pill Community
- app_exception_dart Community
- lib_core_services_translation_backend Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_constants_app_strings_appstrings Community
- package_translatoo_core_constants_app_constants_dart Community
- dart_io Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 17 edges
2. `_` - 17 edges
3. `SpeechViewModel` - 15 edges
4. `ModelManagerService` - 13 edges
5. `TranslationBackend` - 10 edges
6. `AppException` - 9 edges
7. `ModelManagerApi` - 8 edges
8. `Language` - 8 edges
9. `SttAudioSource` - 7 edges
10. `SttService` - 6 edges

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

## Communities (50 total, 1 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (65): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+57 more)

### Community 1 - "connectivityplatform Community"
Cohesion: 0.05
Nodes (45): ConnectivityPlatform, File, actions, build, child, expandChild, footer, leading (+37 more)

### Community 2 - "icon Community"
Cohesion: 0.04
Nodes (48): Icon, SttEngineSession, _WhisperSession, package:translatoo/ui/widgets/listening_sheet.dart, package:translatoo/ui/widgets/mic_button.dart, package:translatoo/ui/widgets/waveform.dart, Partial, _FakeSession (+40 more)

### Community 3 - "level Community"
Cohesion: 0.04
Nodes (48): Level, RecordAudioSource, amplitude, _armPauseTimer, _audio, _audioSub, cancel, dispose (+40 more)

### Community 4 - "bool_get Community"
Cohesion: 0.05
Nodes (45): bool get, ChangeNotifier, ../core/services/connectivity_service.dart, ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/record_audio_source.dart, core/services/storage_service.dart, ../core/services/stt_service.dart (+37 more)

### Community 5 - "datetime Community"
Cohesion: 0.04
Nodes (44): DateTime, language.dart, AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson (+36 more)

### Community 6 - "errorcode_get Community"
Cohesion: 0.05
Nodes (42): ErrorCode? get, acknowledgeError, _amplitudeSub, cancel, _canDictate, _clearError, dispose, _elapsedSeconds (+34 more)

### Community 7 - "test_state_speech_view_model_test Community"
Cohesion: 0.05
Nodes (41): afterRequest, _amplitude, audio, backend, build, _bytes, current, deleteModel (+33 more)

### Community 8 - "audiorecorder Community"
Cohesion: 0.05
Nodes (38): AudioRecorder, Connectivity, dart:async, dart:typed_data, _apply, _connectivity, dispose, isOnline (+30 more)

### Community 9 - "appexception_get Community"
Cohesion: 0.05
Nodes (39): AppException? get, Language get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, confirmDownloadAnyway (+31 more)

### Community 10 - "fakeaudio Community"
Cohesion: 0.05
Nodes (38): _FakeAudio, _FakeEngine, _FakeSession?, static final Uint8List, _amplitude, audio, _bytes, close (+30 more)

### Community 11 - "lib_core_constants_app_constants Community"
Cohesion: 0.06
Nodes (35): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+27 more)

### Community 12 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (33): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+25 more)

### Community 13 - "applifecyclelistener Community"
Cohesion: 0.08
Nodes (28): AppLifecycleListener, ../../core/services/app_exception.dart, build, TranslatooApp, TranslatorViewModel, _controller, _copyTranslation, createState (+20 more)

### Community 14 - "appsettings_get Community"
Cohesion: 0.07
Nodes (26): AppSettings get, Duration, dispose, _disposed, _favorites, flush, _flushing, _flushTimer (+18 more)

### Community 15 - "constants_app_colors_dart Community"
Cohesion: 0.07
Nodes (25): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge (+17 more)

### Community 16 - "dart_math Community"
Cohesion: 0.07
Nodes (25): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+17 more)

### Community 17 - "color Community"
Cohesion: 0.08
Nodes (22): Color, CustomPainter, AppSpacing, lg, md, minTouchTarget, radius, sm (+14 more)

### Community 18 - "package_translatoo_core_services_whisper_stt_engine_dart Community"
Cohesion: 0.09
Nodes (22): package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/state/speech_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, amplitude, complete, deleteModel, dispose (+14 more)

### Community 19 - "animation Community"
Cohesion: 0.11
Nodes (21): Animation, TranslateScreen, _TranslateScreenState, animation, build, color, createState, dispose (+13 more)

### Community 20 - "completer Community"
Cohesion: 0.09
Nodes (21): Completer, _EchoBackend, _FakeApi, package:translatoo/state/translator_view_model.dart, api, backend, build, deleteModel (+13 more)

### Community 21 - "package_translatoo_core_services_whisper_model_installer_dart Community"
Cohesion: 0.12
Nodes (16): package:translatoo/core/services/whisper_model_installer.dart, assetBytes, assetError, assetKey, bytes, expectedPath, files, fileSizeBytes (+8 more)

### Community 22 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.17
Nodes (16): SpeechViewModel, _onMicPressed, _OriginFooter, _showBlockedDialog, _, build, elapsed, _format (+8 more)

### Community 23 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 24 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.13
Nodes (14): package:translatoo/core/services/translation_backend.dart, package:translatoo/core/services/translation_service.dart, beginCapture, dispose, id, isModelDownloaded, isReady, main (+6 more)

### Community 25 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 26 - "dart_convert Community"
Cohesion: 0.15
Nodes (12): dart:convert, package:fake_async/fake_async.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/translation_record.dart, main, _record, getInstance (+4 more)

### Community 27 - "future Community"
Cohesion: 0.14
Nodes (13): Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation, modelsDirectory (+5 more)

### Community 28 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 29 - "package_flutter_test_flutter_test_dart Community"
Cohesion: 0.18
Nodes (9): package:flutter_test/flutter_test.dart, package:translatoo/core/services/record_audio_source.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/language_pair.dart, main, main, main (+1 more)

### Community 30 - "core_constants_app_spacing_dart Community"
Cohesion: 0.17
Nodes (10): ../../core/constants/app_spacing.dart, IconData, build, ConnectionBadge, isOnline, build, icon, message (+2 more)

### Community 31 - "core_constants_app_strings_dart Community"
Cohesion: 0.20
Nodes (9): ../../core/constants/app_strings.dart, build, HistoryScreen, build, SettingsScreen, package:flutter/material.dart, package:translatoo/core/constants/app_strings.dart, main (+1 more)

### Community 32 - "exception Community"
Cohesion: 0.17
Nodes (11): Exception, AppException, cause, code, ErrorCode, stackTrace, SuggestedAction, toString (+3 more)

### Community 33 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 34 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+3 more)

### Community 35 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 36 - "animationcontroller Community"
Cohesion: 0.18
Nodes (10): AnimationController, BorderRadius?, borderRadius, build, _controller, createState, dispose, height (+2 more)

### Community 37 - "core_services_model_manager_service_dart Community"
Cohesion: 0.27
Nodes (9): ../../core/services/model_manager_service.dart, ModelManagerService, build, DebugModelsScreen, language, _ModelTile, state, build (+1 more)

### Community 38 - "core_constants_app_constants_dart Community"
Cohesion: 0.22
Nodes (8): ../../core/constants/app_constants.dart, build, DownloadProgressCard, language, onCancel, onDownload, state, VoidCallback

### Community 39 - "int_get Community"
Cohesion: 0.31
Nodes (8): int get, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator, progressPercent

### Community 40 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.22
Nodes (9): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _StubBackend, _EchoBackend (+1 more)

### Community 41 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, mlKitCode, sttCode, tryFromCode, ttsCode, String get

### Community 42 - "lib_ui_widgets_language_pill Community"
Cohesion: 0.22
Nodes (8): build, language, LanguagePill, onSelected, semanticLabel, ../../models/language.dart, String?, ValueChanged

### Community 43 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, translation_backend.dart

### Community 44 - "lib_core_services_translation_backend Community"
Cohesion: 0.29
Nodes (6): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart

### Community 45 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.33
Nodes (6): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 46 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.40
Nodes (5): MicPermissionApi, PlatformMicPermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 47 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 48 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **739 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+734 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `datetime Community` to `core_services_model_manager_service_dart Community`, `core_constants_app_constants_dart Community`, `lib_models_language Community`, `lib_ui_widgets_language_pill Community`, `appexception_get Community`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `SpeechViewModel` connect `lib_state_speech_view_model_speechviewmodel Community` to `icon Community`, `bool_get Community`, `errorcode_get Community`, `test_state_speech_view_model_test Community`, `applifecyclelistener Community`, `package_translatoo_core_services_whisper_stt_engine_dart Community`, `animation Community`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `AppException` connect `exception Community` to `package_translatoo_core_services_mic_permission_service_dart Community`, `appexception_get Community`, `fakeaudio Community`, `applifecyclelistener Community`, `package_translatoo_core_services_whisper_model_installer_dart Community`, `package_translatoo_core_services_translation_backend_dart Community`, `package_translatoo_core_services_app_exception_dart Community`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _739 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Should `connectivityplatform Community` be split into smaller, more focused modules?**
  _Cohesion score 0.045068027210884355 - nodes in this community are weakly interconnected._
- **Should `icon Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04251700680272109 - nodes in this community are weakly interconnected._