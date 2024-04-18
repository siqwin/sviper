import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';

import 'package:sviper_generator/src/extensions/string_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';
import 'package:sviper_generator/src/entities/constants.dart';

class ModuleBuilder extends GeneratorClassBase {
  ModuleBuilder(super.i) : super(classSuffix: i.options.module);

  @override
  Library? build() {
    final moduleClass = i.classInfo.module.clazz;
    if (moduleClass == null) {
      return null;
    }

    final inputClass = i.classInfo.input.clazz ?? i.classInfo.extendsClassInfo?.input.clazz;
    final outputClass = i.classInfo.output.clazz;

    final interactorClassTarget = i.classInfo.interactor.getNearClassDeclaration();
    final interactorBaseTarget = i.classInfo.interactor.getNearBaseDeclaration();
    final interactorInterfaceTarget = i.classInfo.interactor.getNearInterfaceDeclaration();

    final viewBaseTarget = i.classInfo.view.getNearBaseDeclaration();
    final viewClassTarget = i.classInfo.view.getNearClassDeclaration();

    final presenterBaseTarget = i.classInfo.presenter.getNearBaseDeclaration();
    final presenterClassTarget = i.classInfo.presenter.getNearClassDeclaration();

    final configurationTarget = i.classInfo.configuration.getNearBaseDeclaration();

    final stateClassTarget = i.classInfo.state.getNearClassDeclaration();

    final routerBaseTarget = i.classInfo.router.getNearBaseDeclaration();
    final routerClassTarget = i.classInfo.router.getNearClassDeclaration();

    return Library((l) => l
      ..directives.addAll([
        if (inputClass != null)
          Directive((d) => d
            ..type = DirectiveType.export
            ..url = inputClass.ref.url),
        if (outputClass != null)
          Directive((d) => d
            ..type = DirectiveType.export
            ..url = outputClass.ref.url),
      ])
      ..body.addAll([
        Class((c) => c
          ..name = moduleClass.ref.symbol
          ..types.addAll(i.classInfo.genericParams)
          ..extend = moduleClass.base?.ref.unbound()
          ..constructors.add(Constructor((c) => c
            ..constant = true
            ..requiredParameters.addAll([
              if (inputClass != null)
                Parameter((p) => p
                  ..name = i.options.input.uncap
                  ..toSuper = true),
            ])
            ..optionalParameters.add(Parameter((p) => p
              ..name = "key"
              ..toSuper = true
              ..named = true))))
          ..methods.addAll([
            if (viewBaseTarget != null)
              Method((m) => m
                ..name = "build${i.options.view.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = viewBaseTarget.ref.unbound()
                ..body = Block((u) => u..statements.addNotNull(viewClassTarget?.ref.unbound().call([]).returned.statement))),
            if (presenterBaseTarget != null && configurationTarget != null)
              Method((m) => m
                ..name = "build${i.options.presenter.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = presenterBaseTarget.ref.unbound()
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "configuration"
                  ..type = configurationTarget.ref.unbound()))
                ..body = Block((u) => u..statements.addNotNull(presenterClassTarget?.ref.unbound().call([const CodeExpression(Code("configuration"))]).returned.statement))),
            if (stateClassTarget != null && stateClassTarget.base != null)
              Method((m) => m
                ..name = "build${i.options.state.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = stateClassTarget.ref.unbound()
                ..requiredParameters.addAll([
                  if (interactorInterfaceTarget != null)
                    Parameter((p) => p
                      ..name = i.options.interactor.uncap
                      ..type = interactorInterfaceTarget.ref.unbound().removeUrl())
                ])
                ..body = Block((u) => u..statements.add(stateClassTarget.ref.unbound().call([]).returned.statement))),
            if (interactorBaseTarget != null)
              Method((m) => m
                ..name = "build${i.options.interactor.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = interactorBaseTarget.ref.unbound()
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "context"
                  ..type = buildContextReference))
                ..body = Block((u) => u..statements.addNotNull(interactorClassTarget?.ref.unbound().call([]).returned.statement))),
            if (routerBaseTarget != null)
              Method((m) => m
                ..name = "build${i.options.router.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = routerBaseTarget.ref.unbound()
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "context"
                  ..type = buildContextReference))
                ..body = Block((u) => u..statements.addNotNull(routerClassTarget?.ref.unbound().newInstance([]).returned.statement))),
          ]))
      ]));
  }
}
