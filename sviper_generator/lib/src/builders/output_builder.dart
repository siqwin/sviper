import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/builders/contracts_base_builder.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class OutputBuilder extends GeneratorClassBase {
  OutputBuilder(super.i) : super(classSuffix: i.options.output);

  @override
  Future<Library?> build() async {
    final output = i.classInfo.output.clazz;
    if (output == null) {
      return null;
    }

    final outputClassElement = await getClassElementForExtendClass(output.base);
    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = output.ref.symbol
        ..types.addAll(output.ref.types)
        ..implements.addNotNull(output.interface?.ref.unbound())
        ..constructors.addAll(outputClassElement?.constructors.toConstructorList() ?? [Constructor((c) => c..constant = true)]))));
  }
}
