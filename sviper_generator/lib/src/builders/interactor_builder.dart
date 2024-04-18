import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class InteractorBuilder extends GeneratorClassBase {
  InteractorBuilder(super.i) : super(classSuffix: i.options.interactor);

  @override
  Library? build() {
    final interactor = i.classInfo.interactor.clazz;
    if (interactor == null) {
      return null;
    }

    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = interactor.ref.symbol
        ..types.addAll(i.classInfo.genericParams)
        ..extend = interactor.base?.ref.unbound()
        ..implements.addNotNull(interactor.interface?.ref.unbound().removeUrl()))));
  }
}
