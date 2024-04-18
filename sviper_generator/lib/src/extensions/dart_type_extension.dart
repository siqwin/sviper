import 'package:analyzer/dart/element/type.dart';

extension DartTypeExt on DartType {
  bool get isDartType =>
      isDartCoreObject ||
      isDartCoreInt ||
      isDartCoreSymbol ||
      isDartCoreBool ||
      isDartCoreBool ||
      isDartCoreDouble ||
      isDartCoreEnum ||
      isDartCoreFunction ||
      isDartCoreIterable ||
      isDartCoreList ||
      isDartCoreMap ||
      isDartCoreNum ||
      isDartCoreRecord ||
      isDartCoreSet ||
      isDartCoreString;
}
