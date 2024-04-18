import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class StateBuilder extends GeneratorClassBase {
  StateBuilder(super.i) : super(classSuffix: i.options.state);

  @override
  Library? build() {
    final state = i.classInfo.state.clazz;
    if (state == null) {
      return null;
    }

    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = state.ref.symbol
        ..types.addAll(state.ref.types)
        ..extend = state.base?.ref.unbound()
        ..implements.addNotNull(state.interface?.ref.unbound().removeUrl()))));
  }
}
