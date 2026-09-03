import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'app_exception.dart';

/// Ponte MÍNIMA sobre o asset bundle e o sistema de arquivos (F2.1). Existe
/// pelo mesmo motivo do `ModelManagerApi` da F1.3: isolar a plataforma atrás
/// de uma interface que os testes possam falsificar.
abstract interface class WhisperAssetStorage {
  /// Bytes do asset embutido no APK/IPA.
  Future<Uint8List> readAsset(String assetKey);

  /// Diretório de dados do app onde o modelo passa a viver.
  Future<String> modelsDirectory();

  /// Tamanho do arquivo em bytes, ou `null` se ele não existe.
  Future<int?> fileSizeBytes(String path);

  Future<void> writeFile(String path, Uint8List bytes);
}

/// Implementação real sobre `rootBundle` + `path_provider`.
final class PlatformWhisperAssetStorage implements WhisperAssetStorage {
  @override
  Future<Uint8List> readAsset(String assetKey) async {
    final data = await rootBundle.load(assetKey);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Future<String> modelsDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/${AppConstants.whisperModelsDirName}';
  }

  @override
  Future<int?> fileSizeBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.length();
  }

  @override
  Future<void> writeFile(String path, Uint8List bytes) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}

/// Materializa o modelo ggml embutido como ARQUIVO REAL no diretório de dados
/// (F2.1).
///
/// POR QUE ISTO EXISTE: o whisper.cpp abre o modelo por caminho de arquivo via
/// FFI; um asset do bundle Flutter não tem caminho que o código nativo saiba
/// abrir (no Android ele vive comprimido dentro do APK). A cópia acontece uma
/// única vez, na primeira escuta.
///
/// A comparação de tamanho é o critério de "já instalado": basta para detectar
/// tanto a primeira execução quanto a troca de modelo por atualização do app
/// (base ↔ tiny têm tamanhos bem distintos), sem pagar o hash de 57 MB a cada
/// abertura. O procedimento de atualização está em `docs/whisper_models.md`.
///
/// Toda falha vira `AppException(ErrorCode.sttEngine)` — nenhuma exceção de
/// I/O crua atravessa para o `SttService` ou para a UI (RN-03).
class WhisperModelInstaller {
  WhisperModelInstaller({required this.assetKey, WhisperAssetStorage? storage})
    : _storage = storage ?? PlatformWhisperAssetStorage();

  /// Chave do asset embutido (ex.: `assets/models/whisper/ggml-base-q5_1.bin`).
  final String assetKey;

  final WhisperAssetStorage _storage;

  /// Memoiza a instalação: chamadas concorrentes (dois toques no 🎤) compartilham
  /// a mesma cópia em vez de escreverem 57 MB em paralelo sobre o mesmo arquivo.
  Future<String>? _installation;

  /// Nome do arquivo de destino, derivado do asset.
  String get fileName => assetKey.split('/').last;

  /// Garante o modelo em disco e devolve o caminho absoluto.
  Future<String> ensureInstalled() => _installation ??= _install();

  Future<String> _install() async {
    try {
      final dir = await _storage.modelsDirectory();
      final path = '$dir/$fileName';

      final bytes = await _storage.readAsset(assetKey);
      if (await _storage.fileSizeBytes(path) == bytes.lengthInBytes) {
        return path;
      }

      await _storage.writeFile(path, bytes);
      return path;
    } on AppException {
      rethrow;
    } catch (e, st) {
      // Uma instalação falha não pode envenenar as próximas: a próxima escuta
      // tenta de novo (disco pode ter liberado espaço).
      _installation = null;
      throw AppException(ErrorCode.sttEngine, cause: e, stackTrace: st);
    }
  }
}
