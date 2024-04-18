import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/builders/contracts_base_builder.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class InputBuilder extends GeneratorClassBase {
  InputBuilder(super.i) : super(classSuffix: i.options.input);

  @override
  Future<Library?> build() async {
    final input = i.classInfo.input.clazz;
    if (input == null) {
      return null;
    }

    final inputClassElement = await getClassElementForExtendClass(input.base);
    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = input.ref.symbol
        ..types.addAll(input.ref.types)
        ..implements.addNotNull(input.interface?.ref.unbound())
        ..constructors.addAll(inputClassElement?.constructors.toConstructorList() ?? [Constructor((c) => c..constant = true)]))));
  }
}
