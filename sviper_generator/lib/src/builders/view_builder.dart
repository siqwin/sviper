import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/builders/base/builder_class_base.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/entities/constants.dart';

class ViewBuilder extends GeneratorClassBase {
  ViewBuilder(super.i) : super(classSuffix: i.options.view);

  @override
  Library? build() {
    final view = i.classInfo.view.clazz;
    if (view == null) {
      return null;
    }

    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = view.ref.symbol
        ..types.addAll(i.classInfo.genericParams)
        ..extend = view.base?.ref.unbound()
        ..methods.add(Method((m) => m
          ..name = "build"
          ..annotations.add(overrideAnnotation)
          ..body = const Code("return const Scaffold();")
          ..returns = widgetType
          ..requiredParameters.add(Parameter(
            (p) => p
              ..name = "context"
              ..type = buildContextReference,
          )))))));
  }
}
