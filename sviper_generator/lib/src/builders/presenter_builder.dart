import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class PresenterBuilder extends GeneratorClassBase {
  PresenterBuilder(super.i) : super(classSuffix: i.options.presenter);

  @override
  Library? build() {
    final presenter = i.classInfo.presenter.clazz;
    if (presenter == null) {
      return null;
    }

    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = presenter.ref.symbol
        ..types.addAll(presenter.ref.types)
        ..extend = presenter.base?.ref.unbound()
        ..implements.addNotNull(presenter.interface?.ref.unbound().removeUrl())
        ..constructors.add(Constructor((c) => c
          ..requiredParameters.add(Parameter((p) => p
            ..name = "configuration"
            ..toSuper = true)))))));
  }
}
