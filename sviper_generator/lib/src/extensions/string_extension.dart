import 'package:analyzer/source/source_range.dart';

extension StringExtension on String {
  String withIndent({String indent = "\t", String before = "\t", String after = "\n"}) {
    return "$before${replaceAll("\n", "\n$indent")}$after";
  }

  String trimSpaces() {
    return split(RegExp(r"\s+")).join(" ");
  }

  String withoutExtension() {
    final dotIndex = indexOf(".");
    if (dotIndex == -1) {
      return this;
    }
    return substring(0, dotIndex);
  }

  SourceRange? findClassSourceRange(String className) {
    final startIndex = indexOf(RegExp("class $className[\\s\\t\\r\\n]*"));
    if (startIndex == -1) {
      return null;
    }
    var count = 0;
    var started = false;
    var endIndex = startIndex + 1;
    while (endIndex < codeUnits.length) {
      final curCodeUnit = codeUnits[endIndex];
      if (curCodeUnit == 125) {
        count--;
      } else if (curCodeUnit == 123) {
        count++;
        started = true;
      }
      if (started && count == 0) {
        return SourceRange(startIndex, endIndex - startIndex);
      }
      endIndex++;
    }
    return null;
  }

  String get uncap {
    if (length <= 1) {
      return toLowerCase();
    }
    return "${substring(0, 1).toLowerCase()}${substring(1)}";
  }

  String get cap {
    if (length <= 1) {
      return toUpperCase();
    }
    return "${substring(0, 1).toUpperCase()}${substring(1)}";
  }
}
