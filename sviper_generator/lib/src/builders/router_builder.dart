import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';

import 'package:sviper_generator/src/builders/base/builder_class_base.dart';
import 'package:sviper_generator/src/entities/constants.dart';

class RouterBuilder extends GeneratorClassBase {
  RouterBuilder(super.i) : super(classSuffix: i.options.router);

  @override
  Library? build() {
    final router = i.classInfo.router.clazz;
    if (router == null) {
      return null;
    }

    final hasParent = i.classInfo.router.base?.base?.interface != null;
    return Library((l) => l
      ..body.add(Class((c) => c
        ..name = router.ref.symbol
        ..types.addAll(router.ref.types)
        ..extend = router.base?.ref.unbound()
        ..implements.addNotNull(router.interface?.ref.unbound().removeUrl())
        ..constructors.add(Constructor((c) => c
          ..requiredParameters.add(Parameter((p) => p
            ..name = "router"
            ..toThis = !hasParent
            ..toSuper = hasParent))))
        ..fields.addNotNull(hasParent
            ? null
            : Field(
                (f) => f
                  ..modifier = FieldModifier.final$
                  ..name = "router"
                  ..annotations.add(overrideAnnotation)
                  ..type = sviperRouterInterfaceReference.rebuild((t) => t..types.add(i.classInfo.output.interface?.ref.unbound() ?? voidReference)),
              )))));
  }
}
