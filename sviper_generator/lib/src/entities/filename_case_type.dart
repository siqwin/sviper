import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart' as re;

enum FileNameCaseType {
  pascal,
  camel,
  snake;

  static FileNameCaseType parse(String value) {
    final type = FileNameCaseType.values.firstWhereOrNull((it) => it.name == value);
    if (type == null) {
      log.warning("Unknown value '$value' for 'filename_case' option. Proper values: ${FileNameCaseType.values.map((e) => e.name).join(", ")}");
    }
    return type ?? FileNameCaseType.pascal;
  }

  static FileNameCaseType parseByFileName(String fileName) {
    var targetName = fileName;
    final dotIndex = targetName.indexOf(".");
    if (dotIndex > 0) {
      targetName = targetName.substring(0, dotIndex);
    }
    if (targetName == targetName.pascalCase) {
      return FileNameCaseType.pascal;
    } else if (targetName == targetName.camelCase) {
      return FileNameCaseType.camel;
    } else if (targetName == targetName.snakeCase) {
      return FileNameCaseType.snake;
    }
    return FileNameCaseType.snake;
  }
}
