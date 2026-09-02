# Graph Report - .  (2026-09-01)

## Corpus Check
- 64 files · ~26,416 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1038 nodes · 1457 edges · 53 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- lib_core_constants_app_strings Community
- connectivity Community
- datetime Community
- errorcode_get Community
- appexception_get Community
- icon Community
- test_state_speech_view_model_test Community
- dart_io Community
- fakeaudio Community
- lib_core_constants_app_constants Community
- lib_core_services_model_manager_service Community
- applifecyclelistener Community
- appsettings_get Community
- dart_math Community
- connectivityplatform Community
- core_services_mic_permission_service_dart Community
- completer Community
- dart_convert Community
- package_translatoo_state_speech_view_model_dart Community
- package_translatoo_core_constants_app_spacing_dart Community
- animationcontroller Community
- package_translatoo_core_services_translation_backend_dart Community
- changenotifier Community
- lib_core_constants_app_typography Community
- lib_core_services_translation_service Community
- lib_state_speech_view_model_speechviewmodel Community
- constants_app_constants_dart Community
- future Community
- package_translatoo_core_services_app_exception_dart Community
- animation Community
- lib_core_services_whisper_stt_engine Community
- constants_app_colors_dart Community
- core_constants_app_spacing_dart Community
- core_constants_app_strings_dart Community
- lib_core_services_mic_permission_service Community
- lib_core_services_mlkit_translation_backend Community
- package_translatoo_core_services_mic_permission_service_dart Community
- core_services_model_manager_service_dart Community
- dart_typed_data Community
- lib_core_constants_app_spacing Community
- bool_get Community
- color Community
- lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community
- lib_models_language Community
- lib_ui_widgets_language_pill Community
- app_exception_dart Community
- lib_core_services_translation_backend Community
- lib_core_services_stt_service_sttenginesession Community
- lib_core_services_whisper_model_installer_platformwhisperassetstorage Community
- lib_core_services_mic_permission_service_micpermissionapi Community
- lib_core_services_stt_service_sttengine Community
- lib_core_constants_app_strings_appstrings Community
- package_translatoo_core_constants_app_constants_dart Community

## God Nodes (most connected - your core abstractions)
1. `TranslatorViewModel` - 17 edges
2. `_` - 16 edges
3. `SpeechViewModel` - 15 edges
4. `ModelManagerService` - 13 edges
5. `TranslationBackend` - 10 edges
6. `AppException` - 9 edges
7. `ModelManagerApi` - 8 edges
8. `Language` - 8 edges
9. `SttService` - 6 edges
10. `WhisperAssetStorage` - 6 edges

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

## Communities (53 total, 0 thin omitted)

### Community 0 - "lib_core_constants_app_strings Community"
Cohesion: 0.03
Nodes (65): actionCancel, actionClear, actionCopy, actionDelete, actionDictate, actionDownload, actionDownloadAnyway, actionFavorite (+57 more)

### Community 1 - "connectivity Community"
Cohesion: 0.04
Nodes (46): Connectivity, dart:async, _apply, _connectivity, dispose, isOnline, isOnMobileData, start (+38 more)

### Community 2 - "datetime Community"
Cohesion: 0.04
Nodes (44): DateTime, language.dart, AppSettings, autoPlay, cloudEnabled, copyWith, defaults, fromJson (+36 more)

### Community 3 - "errorcode_get Community"
Cohesion: 0.05
Nodes (43): ErrorCode? get, int get, hashCode, ModelDownloading, ModelNotDownloaded, ModelReady, ModelState, operator (+35 more)

### Community 4 - "appexception_get Community"
Cohesion: 0.05
Nodes (39): AppException? get, Language get, acceptDictatedText, _blockedLanguageLabel, _cancelDebounce, canDictate, clearSource, confirmDownloadAnyway (+31 more)

### Community 5 - "icon Community"
Cohesion: 0.05
Nodes (38): Icon, package:translatoo/ui/widgets/listening_sheet.dart, package:translatoo/ui/widgets/mic_button.dart, _bytes, cancel, deleteModel, dispose, downloadModel (+30 more)

### Community 6 - "test_state_speech_view_model_test Community"
Cohesion: 0.05
Nodes (38): afterRequest, backend, build, _bytes, current, deleteModel, dispose, downloadModel (+30 more)

### Community 7 - "dart_io Community"
Cohesion: 0.06
Nodes (33): dart:io, Exception, File, AppException, cause, code, ErrorCode, stackTrace (+25 more)

### Community 8 - "fakeaudio Community"
Cohesion: 0.05
Nodes (36): _FakeAudio, _FakeEngine, _FakeSession?, static final Uint8List, audio, _bytes, close, emit (+28 more)

### Community 9 - "lib_core_constants_app_constants Community"
Cohesion: 0.05
Nodes (36): AppConstants, chunkBlockChars, cloudTimeout, enableAlternativeEngine, estimatedModelSizeMb, favorites, hasEmbeddedSttModels, history (+28 more)

### Community 10 - "lib_core_services_model_manager_service Community"
Cohesion: 0.06
Nodes (33): _api, cancelDownload, deleteModel, dispose, downloadModel, evaluateDownloadGate, _internalStates, _isCurrent (+25 more)

### Community 11 - "applifecyclelistener Community"
Cohesion: 0.08
Nodes (30): AppLifecycleListener, ../../core/services/app_exception.dart, build, TranslatooApp, TranslatorViewModel, _controller, _copyTranslation, createState (+22 more)

### Community 12 - "appsettings_get Community"
Cohesion: 0.07
Nodes (26): AppSettings get, Duration, dispose, _disposed, _favorites, flush, _flushing, _flushTimer (+18 more)

### Community 13 - "dart_math Community"
Cohesion: 0.07
Nodes (25): dart:math, dart:ui, AppColorsDark, AppColorsLight, colorBackground, colorBorder, colorError, colorOnPrimary (+17 more)

### Community 14 - "connectivityplatform Community"
Cohesion: 0.09
Nodes (21): ConnectivityPlatform, actions, build, child, expandChild, footer, leading, TranslationCard (+13 more)

### Community 15 - "core_services_mic_permission_service_dart Community"
Cohesion: 0.09
Nodes (21): ../core/services/mic_permission_service.dart, core/services/mlkit_translation_backend.dart, core/services/storage_service.dart, ../core/services/stt_service.dart, core/services/tflite_translation_backend.dart, ../core/services/translation_service.dart, core/services/unavailable_audio_source.dart, core/services/whisper_model_installer.dart (+13 more)

### Community 16 - "completer Community"
Cohesion: 0.10
Nodes (20): Completer, _EchoBackend, _FakeApi, api, backend, build, deleteModel, dispose (+12 more)

### Community 17 - "dart_convert Community"
Cohesion: 0.12
Nodes (17): dart:convert, package:fake_async/fake_async.dart, package:flutter_test/flutter_test.dart, package:shared_preferences/shared_preferences.dart, package:translatoo/core/services/storage_service.dart, package:translatoo/models/app_settings.dart, package:translatoo/models/language.dart, package:translatoo/models/translation_record.dart (+9 more)

### Community 18 - "package_translatoo_state_speech_view_model_dart Community"
Cohesion: 0.10
Nodes (19): package:translatoo/state/speech_view_model.dart, package:translatoo/state/translator_view_model.dart, package:translatoo/ui/screens/translate_screen.dart, package:translatoo/ui/widgets/download_progress_card.dart, complete, deleteModel, dispose, downloadModel (+11 more)

### Community 19 - "package_translatoo_core_constants_app_spacing_dart Community"
Cohesion: 0.11
Nodes (18): package:translatoo/core/constants/app_spacing.dart, package:translatoo/core/services/stt_service.dart, package:translatoo/core/services/unavailable_audio_source.dart, package:translatoo/core/services/whisper_stt_engine.dart, package:translatoo/main.dart, RoundedRectangleBorder, checkConnectivity, deleteModel (+10 more)

### Community 20 - "animationcontroller Community"
Cohesion: 0.13
Nodes (17): AnimationController, BorderRadius?, MicButton, _MicButtonState, borderRadius, build, _controller, createState (+9 more)

### Community 21 - "package_translatoo_core_services_translation_backend_dart Community"
Cohesion: 0.11
Nodes (16): package:translatoo/core/services/translation_backend.dart, package:translatoo/core/services/translation_service.dart, package:translatoo/models/language_pair.dart, main, beginCapture, dispose, id, isModelDownloaded (+8 more)

### Community 22 - "changenotifier Community"
Cohesion: 0.14
Nodes (16): ChangeNotifier, debug_models_screen.dart, history_screen.dart, ConnectionViewModel, build, createState, HomeScreen, _HomeScreenState (+8 more)

### Community 23 - "lib_core_constants_app_typography Community"
Cohesion: 0.13
Nodes (14): AppTypography, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall, labelLarge, labelMedium (+6 more)

### Community 24 - "lib_core_services_translation_service Community"
Cohesion: 0.13
Nodes (14): activeBackend, dispose, _fallback, _fallbackEnabled, isReady, _logLatency, _primary, translate (+6 more)

### Community 25 - "lib_state_speech_view_model_speechviewmodel Community"
Cohesion: 0.18
Nodes (15): SpeechViewModel, _onMicPressed, _OriginFooter, _showBlockedDialog, DownloadProgressCard, _, build, elapsed (+7 more)

### Community 26 - "constants_app_constants_dart Community"
Cohesion: 0.14
Nodes (13): ../constants/app_constants.dart, _breakUnits, chunks, chunkText, _findCutIndex, high, index, low (+5 more)

### Community 27 - "future Community"
Cohesion: 0.14
Nodes (13): Future, assetKey, ensureInstalled, fileName, fileSizeBytes, _install, _installation, modelsDirectory (+5 more)

### Community 28 - "package_translatoo_core_services_app_exception_dart Community"
Cohesion: 0.14
Nodes (12): package:translatoo/core/services/app_exception.dart, package:translatoo/core/services/model_manager_service.dart, package:translatoo/models/model_state.dart, main, completeDownload, deleteModel, downloadModel, failDownload (+4 more)

### Community 29 - "animation Community"
Cohesion: 0.15
Nodes (12): Animation, animation, build, color, createState, dispose, maybe, onPressed (+4 more)

### Community 30 - "lib_core_services_whisper_stt_engine Community"
Cohesion: 0.15
Nodes (12): _controller, feed, _noAudio, partials, _session, startSession, stop, package:whisper_ggml/whisper_ggml.dart (+4 more)

### Community 31 - "constants_app_colors_dart Community"
Cohesion: 0.17
Nodes (11): ../constants/app_colors.dart, ../constants/app_spacing.dart, ../constants/app_typography.dart, AppTheme, _build, cjkFallback, dark, light (+3 more)

### Community 32 - "core_constants_app_spacing_dart Community"
Cohesion: 0.17
Nodes (10): ../../core/constants/app_spacing.dart, IconData, build, ConnectionBadge, isOnline, build, icon, message (+2 more)

### Community 33 - "core_constants_app_strings_dart Community"
Cohesion: 0.20
Nodes (9): ../../core/constants/app_strings.dart, build, HistoryScreen, build, SettingsScreen, package:flutter/material.dart, package:translatoo/core/constants/app_strings.dart, main (+1 more)

### Community 34 - "lib_core_services_mic_permission_service Community"
Cohesion: 0.17
Nodes (11): _api, current, _map, MicPermission, MicPermissionService, openSettings, request, status (+3 more)

### Community 35 - "lib_core_services_mlkit_translation_backend Community"
Cohesion: 0.17
Nodes (11): dispose, id, isModelDownloaded, isReady, _mapError, _toPlugin, translate, _translatorFor (+3 more)

### Community 36 - "package_translatoo_core_services_mic_permission_service_dart Community"
Cohesion: 0.17
Nodes (11): package:translatoo/core/services/mic_permission_service.dart, PermissionStatus, afterRequest, initial, main, openSettings, openSettingsCount, platformError (+3 more)

### Community 37 - "core_services_model_manager_service_dart Community"
Cohesion: 0.27
Nodes (9): ../../core/services/model_manager_service.dart, ModelManagerService, build, DebugModelsScreen, language, _ModelTile, state, build (+1 more)

### Community 38 - "dart_typed_data Community"
Cohesion: 0.20
Nodes (9): dart:typed_data, SttAudioSource, start, stop, UnavailableAudioSource, stt_service.dart, _FakeAudio, _FakeAudio (+1 more)

### Community 39 - "lib_core_constants_app_spacing Community"
Cohesion: 0.20
Nodes (9): AppSpacing, lg, md, minTouchTarget, radius, sm, xl, xs (+1 more)

### Community 40 - "bool_get Community"
Cohesion: 0.22
Nodes (8): bool get, ../core/services/connectivity_service.dart, ConnectivityService, dispose, isOnline, _onChanged, _service, package:flutter/foundation.dart

### Community 41 - "color Community"
Cohesion: 0.22
Nodes (8): Color, ../../core/constants/app_constants.dart, build, language, onCancel, onDownload, state, VoidCallback

### Community 42 - "lib_core_services_mlkit_translation_backend_mlkittranslationbackend Community"
Cohesion: 0.22
Nodes (9): MlKitTranslationBackend, TfliteTranslationBackend, TranslationBackend, FakeEchoBackend, _EchoBackend, _EchoBackend, _StubBackend, _EchoBackend (+1 more)

### Community 43 - "lib_models_language Community"
Cohesion: 0.22
Nodes (8): bcp47Code, displayName, jsonCode, mlKitCode, sttCode, tryFromCode, ttsCode, String get

### Community 44 - "lib_ui_widgets_language_pill Community"
Cohesion: 0.22
Nodes (8): build, language, LanguagePill, onSelected, semanticLabel, ../../models/language.dart, String?, ValueChanged

### Community 45 - "app_exception_dart Community"
Cohesion: 0.25
Nodes (7): app_exception.dart, dispose, id, isModelDownloaded, isReady, translate, translation_backend.dart

### Community 46 - "lib_core_services_translation_backend Community"
Cohesion: 0.29
Nodes (6): dispose, id, isModelDownloaded, isReady, translate, ../../models/language_pair.dart

### Community 47 - "lib_core_services_stt_service_sttenginesession Community"
Cohesion: 0.47
Nodes (6): SttEngineSession, _WhisperSession, Partial, _FakeSession, _FakeSession, _FakeSession

### Community 48 - "lib_core_services_whisper_model_installer_platformwhisperassetstorage Community"
Cohesion: 0.33
Nodes (6): PlatformWhisperAssetStorage, WhisperAssetStorage, _InstalledStorage, _FakeStorage, _InstalledStorage, _InstalledStorage

### Community 49 - "lib_core_services_mic_permission_service_micpermissionapi Community"
Cohesion: 0.40
Nodes (5): MicPermissionApi, PlatformMicPermissionApi, _FakeApi, _FakePermissionApi, _GrantedPermissionApi

### Community 50 - "lib_core_services_stt_service_sttengine Community"
Cohesion: 0.40
Nodes (5): SttEngine, WhisperSttEngine, _FakeEngine, _FakeEngine, _FakeEngine

### Community 51 - "lib_core_constants_app_strings_appstrings Community"
Cohesion: 0.50
Nodes (4): AppStrings, _EnStrings, _PtStrings, _ZhStrings

### Community 52 - "package_translatoo_core_constants_app_constants_dart Community"
Cohesion: 0.50
Nodes (3): package:translatoo/core/constants/app_constants.dart, package:translatoo/core/services/text_chunker.dart, main

## Knowledge Gaps
- **699 isolated node(s):** `AppColorsLight`, `AppColorsDark`, `colorPrimary`, `colorPrimaryContainer`, `colorOnPrimary` (+694 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Language` connect `datetime Community` to `appexception_get Community`, `core_services_model_manager_service_dart Community`, `color Community`, `lib_models_language Community`, `lib_ui_widgets_language_pill Community`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Why does `AppException` connect `dart_io Community` to `appexception_get Community`, `package_translatoo_core_services_mic_permission_service_dart Community`, `fakeaudio Community`, `applifecyclelistener Community`, `package_translatoo_core_services_translation_backend_dart Community`, `package_translatoo_core_services_app_exception_dart Community`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **Why does `ModelManagerService` connect `core_services_model_manager_service_dart Community` to `appexception_get Community`, `icon Community`, `test_state_speech_view_model_test Community`, `lib_core_services_model_manager_service Community`, `applifecyclelistener Community`, `core_services_mic_permission_service_dart Community`, `completer Community`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **What connects `AppColorsLight`, `AppColorsDark`, `colorPrimary` to the rest of the system?**
  _699 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `lib_core_constants_app_strings Community` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Should `connectivity Community` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._
- **Should `datetime Community` be split into smaller, more focused modules?**
  _Cohesion score 0.04440333024976873 - nodes in this community are weakly interconnected._