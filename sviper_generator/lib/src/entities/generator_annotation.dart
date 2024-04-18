import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

class GeneratorAnnotation {
  final DartType? extendsType;
  final bool isWidget;

  final bool hasOutput;
  final bool hasInput;
  final bool hasInteractor;
  final bool hasRouter;
  final bool hasView;
  final bool hasPresenter;
  final bool hasState;

  GeneratorAnnotation({
    this.extendsType,
    this.isWidget = false,
    required this.hasInput,
    required this.hasOutput,
    required this.hasInteractor,
    required this.hasRouter,
    required this.hasView,
    required this.hasPresenter,
    required this.hasState,
  });

  factory GeneratorAnnotation.fromAnnotation(ConstantReader annotation) {
    return GeneratorAnnotation(
      isWidget: annotation.peek("isWidget")?.boolValue ?? false,
      extendsType: annotation.peek("extend")?.typeValue,
      hasInput: annotation.peek("hasInput")?.boolValue ?? true,
      hasOutput: annotation.peek("hasOutput")?.boolValue ?? true,
      hasInteractor: annotation.peek("hasInteractor")?.boolValue ?? true,
      hasRouter: annotation.peek("hasRouter")?.boolValue ?? true,
      hasView: annotation.peek("hasView")?.boolValue ?? true,
      hasPresenter: annotation.peek("hasPresenter")?.boolValue ?? true,
      hasState: annotation.peek("hasState")?.boolValue ?? true,
    );
  }
}
