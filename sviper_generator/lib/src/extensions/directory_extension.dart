import 'dart:io';

extension DirectoryExtension on Directory {
  void createSyncIfNotExists({bool recursive = true}) {
    if (!existsSync()) {
      createSync(recursive: recursive);
    }
  }
}
