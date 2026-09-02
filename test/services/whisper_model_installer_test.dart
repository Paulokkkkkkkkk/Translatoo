import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';

/// Sistema de arquivos em memória (F2.1): conta escritas para provar que a
/// cópia de 57 MB acontece UMA vez, e não a cada escuta.
class _FakeStorage implements WhisperAssetStorage {
  _FakeStorage({required this.assetBytes});

  Uint8List assetBytes;
  final Map<String, Uint8List> files = <String, Uint8List>{};

  int writeCount = 0;
  int readAssetCount = 0;
  Object? assetError;
  Object? writeError;

  @override
  Future<Uint8List> readAsset(String assetKey) async {
    readAssetCount++;
    if (assetError != null) throw assetError!;
    return assetBytes;
  }

  @override
  Future<String> modelsDirectory() async => '/data/app/whisper';

  @override
  Future<int?> fileSizeBytes(String path) async => files[path]?.lengthInBytes;

  @override
  Future<void> writeFile(String path, Uint8List bytes) async {
    if (writeError != null) throw writeError!;
    writeCount++;
    files[path] = bytes;
  }
}

void main() {
  const assetKey = 'assets/models/whisper/ggml-base-q5_1.bin';
  const expectedPath = '/data/app/whisper/ggml-base-q5_1.bin';

  Uint8List bytes(int length, {int fill = 7}) =>
      Uint8List.fromList(List<int>.filled(length, fill));

  test('primeira instalação copia o asset e devolve o caminho real', () async {
    final storage = _FakeStorage(assetBytes: bytes(1024));
    final installer = WhisperModelInstaller(
      assetKey: assetKey,
      storage: storage,
    );

    expect(await installer.ensureInstalled(), expectedPath);
    expect(storage.writeCount, 1);
    expect(storage.files[expectedPath]!.lengthInBytes, 1024);
  });

  test('modelo já instalado não é reescrito', () async {
    final storage = _FakeStorage(assetBytes: bytes(1024));
    storage.files[expectedPath] = bytes(1024);

    await WhisperModelInstaller(
      assetKey: assetKey,
      storage: storage,
    ).ensureInstalled();

    expect(storage.writeCount, 0);
  });

  test(
    'tamanho diferente reinstala (troca de modelo na atualização do app)',
    () async {
      final storage = _FakeStorage(assetBytes: bytes(2048));
      storage.files[expectedPath] = bytes(1024);

      await WhisperModelInstaller(
        assetKey: assetKey,
        storage: storage,
      ).ensureInstalled();

      expect(storage.writeCount, 1);
      expect(storage.files[expectedPath]!.lengthInBytes, 2048);
    },
  );

  test('chamadas concorrentes compartilham uma única cópia', () async {
    final storage = _FakeStorage(assetBytes: bytes(1024));
    final installer = WhisperModelInstaller(
      assetKey: assetKey,
      storage: storage,
    );

    final paths = await Future.wait<String>(<Future<String>>[
      installer.ensureInstalled(),
      installer.ensureInstalled(),
      installer.ensureInstalled(),
    ]);

    expect(paths, everyElement(expectedPath));
    expect(storage.writeCount, 1);
    expect(storage.readAssetCount, 1);
  });

  test(
    'falha de I/O vira AppException(sttEngine) sem vazar a causa crua',
    () async {
      final storage = _FakeStorage(assetBytes: bytes(1024))
        ..writeError = const FileSystemException('sem espaço');
      final installer = WhisperModelInstaller(
        assetKey: assetKey,
        storage: storage,
      );

      await expectLater(
        installer.ensureInstalled(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ErrorCode.sttEngine,
          ),
        ),
      );
    },
  );

  test('instalação falha não envenena a próxima tentativa', () async {
    final storage = _FakeStorage(assetBytes: bytes(1024))
      ..writeError = const FileSystemException('sem espaço');
    final installer = WhisperModelInstaller(
      assetKey: assetKey,
      storage: storage,
    );

    await expectLater(
      installer.ensureInstalled(),
      throwsA(isA<AppException>()),
    );

    storage.writeError = null;
    expect(await installer.ensureInstalled(), expectedPath);
    expect(storage.writeCount, 1);
  });
}
