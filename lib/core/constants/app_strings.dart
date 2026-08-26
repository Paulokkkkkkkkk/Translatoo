import 'package:flutter/material.dart';

import '../../models/model_state.dart';
import '../services/app_exception.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// TRANSLATOO — i18n manual (RN-04 / plano F0.5)
///
/// ÚNICA fonte de strings de UI. Proibido texto de interface fora deste
/// arquivo. Idioma da UI = idioma do sistema com fallback pt-BR (v1); a
/// estrutura já aceita override manual futuro (Ajustes, F3).
///
/// Mensagens de erro seguem a Tabela Única de Erros (PRD §4.8).
/// ─────────────────────────────────────────────────────────────────────────
abstract final class AppStrings {
  /// Resolve as strings a partir do [Locale] vigente acima de [context].
  static AppStrings of(BuildContext context) =>
      forLocale(Localizations.localeOf(context));

  /// Lookup puro por locale — fallback pt-BR p/ qualquer idioma não suportado.
  static AppStrings forLocale(Locale locale) =>
      switch (locale.languageCode.toLowerCase()) {
        'en' => const _EnStrings(),
        'zh' => const _ZhStrings(),
        _ => const _PtStrings(),
      };

  const AppStrings();

  // Identidade
  String get appName;

  // Navegação
  String get tabTranslate;
  String get tabHistory;
  String get tabSettings;

  // Conectividade (ConnectionBadge)
  String get online;
  String get offline;

  // Placeholders da fundação (F0)
  String get translatePlaceholderBody;
  String get historyPlaceholderBody;
  String get settingsPlaceholderBody;

  // Ações comuns
  String get actionCancel;
  String get actionDownload;
  String get actionDelete;
  String get actionRetry;
  String get actionOpenSettings;
  String get actionDownloadAnyway;
  String get actionCopy;
  String get actionFavorite;
  String get actionShare;
  String get actionSwapLanguages;

  // Tela Traduzir (M1)
  String get actionPaste;
  String get actionClear;
  String get sourceHint;
  String get charLimitReached;
  String get buttonTranslate;
  String get actionDictate;
  String get actionListen;
  String get comingSoon;
  String get feedbackCopied;
  String get modelSizeEstimate;
  String get engineAlternative;

  // Tela de debug de pacotes (F1.3 — só visível em builds debug)
  String get debugModelsTitle;

  // Estados de pacote de idioma
  String get modelStateReady;
  String get modelStateNotInstalled;
  String get modelStateDownloading;

  // Semantics dos cartões (RN-06)
  String get originLabel;
  String get destinationLabel;

  // Erros — Tabela Única §4.8
  String errModelNotDownloaded(String language);
  String get errDownloadFailed;
  String get errWifiOnly;
  String get errMicPermission;
  String get errSttEngine;
  String errTtsVoiceMissing(String language);
  String get errStorage;
  String get errTranslationFailed;

  // Estados vazios
  String get historyEmpty;

  // Ajustes (textos reservados para a F3)
  String get settingsLanguagePair;
  String get settingsAutoplay;
  String get settingsVoiceRate;
  String get settingsVoicePitch;
  String get settingsWifiOnly;
  String get settingsManageModels;
  String get settingsClearHistory;
  String get settingsPrivacy;
}

/// pt-BR — fonte da verdade (PRD).
final class _PtStrings extends AppStrings {
  const _PtStrings();

  @override
  String get appName => 'Translatoo';

  @override
  String get tabTranslate => 'Traduzir';
  @override
  String get tabHistory => 'Histórico';
  @override
  String get tabSettings => 'Ajustes';

  @override
  String get online => 'Online';
  @override
  String get offline => 'Offline';

  @override
  String get translatePlaceholderBody => 'A tradução offline aparece aqui.';
  @override
  String get historyPlaceholderBody =>
      'Suas traduções ficam salvas apenas neste aparelho.';
  @override
  String get settingsPlaceholderBody =>
      'As preferências do app aparecerão aqui.';

  @override
  String get actionCancel => 'Cancelar';
  @override
  String get actionDownload => 'Baixar';
  @override
  String get actionDelete => 'Excluir';
  @override
  String get actionRetry => 'Tentar novamente';
  @override
  String get actionOpenSettings => 'Abrir configurações';
  @override
  String get actionDownloadAnyway => 'Baixar mesmo assim';
  @override
  String get actionCopy => 'Copiar';
  @override
  String get actionFavorite => 'Favoritar';
  @override
  String get actionShare => 'Compartilhar';
  @override
  String get actionSwapLanguages => 'Trocar idiomas';

  @override
  String get actionPaste => 'Colar';
  @override
  String get actionClear => 'Limpar';
  @override
  String get sourceHint => 'Digite o texto para traduzir';
  @override
  String get charLimitReached =>
      'Limite de 5.000 caracteres atingido. O texto foi truncado.';
  @override
  String get buttonTranslate => 'Traduzir';
  @override
  String get actionDictate => 'Ditar';
  @override
  String get actionListen => 'Ouvir tradução';
  @override
  String get comingSoon => 'chega na próxima fase';
  @override
  String get feedbackCopied => 'Tradução copiada';
  @override
  String get modelSizeEstimate => '~30 MB por pacote · via Wi-Fi';
  @override
  String get engineAlternative => 'Motor alternativo';

  @override
  String get debugModelsTitle => 'Pacotes de idiomas (debug)';

  @override
  String get modelStateReady => 'Pronto';
  @override
  String get modelStateNotInstalled => 'Não instalado';
  @override
  String get modelStateDownloading => 'Baixando';

  @override
  String get originLabel => 'Idioma de origem';
  @override
  String get destinationLabel => 'Idioma de destino';

  @override
  String errModelNotDownloaded(String language) =>
      'Pacote de $language não instalado';
  @override
  String get errDownloadFailed => 'Falha ao baixar pacote';
  @override
  String get errWifiOnly => 'Download restrito a Wi-Fi';
  @override
  String get errMicPermission => 'Precisamos do microfone para ouvir você';
  @override
  String get errSttEngine => 'Não foi possível ouvir agora';
  @override
  String errTtsVoiceMissing(String language) =>
      'Instale a voz $language nas configurações do sistema';
  @override
  String get errStorage => 'Não foi possível salvar';
  @override
  String get errTranslationFailed => 'Tradução indisponível neste momento';

  @override
  String get historyEmpty => 'Nenhuma tradução ainda.';

  @override
  String get settingsLanguagePair => 'Par de idiomas padrão';
  @override
  String get settingsAutoplay => 'Ouvir tradução automaticamente';
  @override
  String get settingsVoiceRate => 'Velocidade da voz';
  @override
  String get settingsVoicePitch => 'Tom da voz';
  @override
  String get settingsWifiOnly => 'Baixar modelos só no Wi-Fi';
  @override
  String get settingsManageModels => 'Gerenciar modelos';
  @override
  String get settingsClearHistory => 'Limpar histórico';
  @override
  String get settingsPrivacy => 'Nenhum dado sai do seu aparelho.';
}

/// en-US
final class _EnStrings extends AppStrings {
  const _EnStrings();

  @override
  String get appName => 'Translatoo';

  @override
  String get tabTranslate => 'Translate';
  @override
  String get tabHistory => 'History';
  @override
  String get tabSettings => 'Settings';

  @override
  String get online => 'Online';
  @override
  String get offline => 'Offline';

  @override
  String get translatePlaceholderBody => 'Offline translations appear here.';
  @override
  String get historyPlaceholderBody =>
      'Your translations are stored only on this device.';
  @override
  String get settingsPlaceholderBody => 'App preferences will appear here.';

  @override
  String get actionCancel => 'Cancel';
  @override
  String get actionDownload => 'Download';
  @override
  String get actionDelete => 'Delete';
  @override
  String get actionRetry => 'Try again';
  @override
  String get actionOpenSettings => 'Open settings';
  @override
  String get actionDownloadAnyway => 'Download anyway';
  @override
  String get actionCopy => 'Copy';
  @override
  String get actionFavorite => 'Favorite';
  @override
  String get actionShare => 'Share';
  @override
  String get actionSwapLanguages => 'Swap languages';

  @override
  String get actionPaste => 'Paste';
  @override
  String get actionClear => 'Clear';
  @override
  String get sourceHint => 'Type text to translate';
  @override
  String get charLimitReached =>
      '5,000-character limit reached. Text was truncated.';
  @override
  String get buttonTranslate => 'Translate';
  @override
  String get actionDictate => 'Dictate';
  @override
  String get actionListen => 'Listen to translation';
  @override
  String get comingSoon => 'coming in the next phase';
  @override
  String get feedbackCopied => 'Translation copied';
  @override
  String get modelSizeEstimate => '~30 MB per package · over Wi-Fi';
  @override
  String get engineAlternative => 'Alternative engine';

  @override
  String get debugModelsTitle => 'Language packages (debug)';

  @override
  String get modelStateReady => 'Ready';
  @override
  String get modelStateNotInstalled => 'Not installed';
  @override
  String get modelStateDownloading => 'Downloading';

  @override
  String get originLabel => 'Source language';
  @override
  String get destinationLabel => 'Target language';

  @override
  String errModelNotDownloaded(String language) =>
      '$language package is not installed';
  @override
  String get errDownloadFailed => 'Failed to download package';
  @override
  String get errWifiOnly => 'Download restricted to Wi-Fi';
  @override
  String get errMicPermission => 'We need the microphone to hear you';
  @override
  String get errSttEngine => "Can't listen right now";
  @override
  String errTtsVoiceMissing(String language) =>
      'Install the $language voice in system settings';
  @override
  String get errStorage => "Couldn't save";
  @override
  String get errTranslationFailed => 'Translation unavailable right now';

  @override
  String get historyEmpty => 'No translations yet.';

  @override
  String get settingsLanguagePair => 'Default language pair';
  @override
  String get settingsAutoplay => 'Listen to translation automatically';
  @override
  String get settingsVoiceRate => 'Voice speed';
  @override
  String get settingsVoicePitch => 'Voice pitch';
  @override
  String get settingsWifiOnly => 'Download models over Wi-Fi only';
  @override
  String get settingsManageModels => 'Manage models';
  @override
  String get settingsClearHistory => 'Clear history';
  @override
  String get settingsPrivacy => 'No data ever leaves your device.';
}

/// zh-CN (Mandarim)
final class _ZhStrings extends AppStrings {
  const _ZhStrings();

  @override
  String get appName => 'Translatoo';

  @override
  String get tabTranslate => '翻译';
  @override
  String get tabHistory => '历史';
  @override
  String get tabSettings => '设置';

  @override
  String get online => '在线';
  @override
  String get offline => '离线';

  @override
  String get translatePlaceholderBody => '离线翻译将显示在这里。';
  @override
  String get historyPlaceholderBody => '翻译记录仅保存在本设备上。';
  @override
  String get settingsPlaceholderBody => '应用偏好设置将显示在这里。';

  @override
  String get actionCancel => '取消';
  @override
  String get actionDownload => '下载';
  @override
  String get actionDelete => '删除';
  @override
  String get actionRetry => '重试';
  @override
  String get actionOpenSettings => '打开设置';
  @override
  String get actionDownloadAnyway => '仍然下载';
  @override
  String get actionCopy => '复制';
  @override
  String get actionFavorite => '收藏';
  @override
  String get actionShare => '分享';
  @override
  String get actionSwapLanguages => '交换语言';

  @override
  String get actionPaste => '粘贴';
  @override
  String get actionClear => '清除';
  @override
  String get sourceHint => '输入要翻译的文字';
  @override
  String get charLimitReached => '已达 5,000 字符上限，文本已截断。';
  @override
  String get buttonTranslate => '翻译';
  @override
  String get actionDictate => '语音输入';
  @override
  String get actionListen => '朗读译文';
  @override
  String get comingSoon => '下一阶段推出';
  @override
  String get feedbackCopied => '译文已复制';
  @override
  String get modelSizeEstimate => '每个语言包约 30 MB · 通过 Wi-Fi 下载';
  @override
  String get engineAlternative => '备用引擎';

  @override
  String get debugModelsTitle => '语言包（调试）';

  @override
  String get modelStateReady => '就绪';
  @override
  String get modelStateNotInstalled => '未安装';
  @override
  String get modelStateDownloading => '下载中';

  @override
  String get originLabel => '源语言';
  @override
  String get destinationLabel => '目标语言';

  @override
  String errModelNotDownloaded(String language) => '尚未安装$language语言包';
  @override
  String get errDownloadFailed => '软件包下载失败';
  @override
  String get errWifiOnly => '仅限通过 Wi-Fi 下载';
  @override
  String get errMicPermission => '我们需要麦克风才能听清您说话';
  @override
  String get errSttEngine => '暂时无法听写';
  @override
  String errTtsVoiceMissing(String language) => '请在系统设置中安装$language语音';
  @override
  String get errStorage => '无法保存';
  @override
  String get errTranslationFailed => '翻译暂时不可用';

  @override
  String get historyEmpty => '暂无翻译记录。';

  @override
  String get settingsLanguagePair => '默认语言对';
  @override
  String get settingsAutoplay => '自动朗读译文';
  @override
  String get settingsVoiceRate => '语速';
  @override
  String get settingsVoicePitch => '音调';
  @override
  String get settingsWifiOnly => '仅通过 Wi-Fi 下载模型';
  @override
  String get settingsManageModels => '管理模型';
  @override
  String get settingsClearHistory => '清除历史记录';
  @override
  String get settingsPrivacy => '任何数据都不会离开您的设备。';
}

/// Mapeamento ÚNICO `ErrorCode` → mensagem i18n da tabela §4.8 (RN-03/RN-04).
/// A UI JAMAIS traduz códigos manualmente — sempre passa por aqui.
///
/// [missingLanguageLabel]: nome nativo do idioma sem pacote, quando conhecido
/// (`errModelNotDownloaded` é parametrizado na tabela). Fallback razoável:
/// rótulo do idioma de origem corrente.
String errorMessageOf(
  AppStrings t,
  ErrorCode code, {
  String? missingLanguageLabel,
}) => switch (code) {
  ErrorCode.modelNotDownloaded => t.errModelNotDownloaded(
    missingLanguageLabel ?? '',
  ),
  ErrorCode.downloadFailed => t.errDownloadFailed,
  ErrorCode.wifiOnly => t.errWifiOnly,
  ErrorCode.micPermission => t.errMicPermission,
  ErrorCode.sttEngine => t.errSttEngine,
  ErrorCode.ttsVoiceMissing => t.errTtsVoiceMissing(missingLanguageLabel ?? ''),
  ErrorCode.storage => t.errStorage,
  ErrorCode.translationFailed => t.errTranslationFailed,
};

/// Rótulo i18n do estado de um pacote (tela de debug F1.3 / cartões).
String modelStateLabel(AppStrings t, ModelState state) => switch (state) {
  ModelReady() => t.modelStateReady,
  ModelDownloading() => t.modelStateDownloading,
  ModelNotDownloaded() => t.modelStateNotInstalled,
};
