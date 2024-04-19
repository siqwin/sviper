import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/extensions/list_builder_extension.dart';

import 'package:sviper_generator/src/extensions/dart_emitter_extension.dart';
import 'package:sviper_generator/src/extensions/string_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_class_base.dart';
import 'package:sviper_generator/src/entities/constants.dart';

class ContractsBaseBuilder extends GeneratorClassBase {
  ContractsBaseBuilder(super.i) : super(classSuffix: "${i.options.module}.$codename");

  @override
  bool get isBuildStepResult => true;

  @override
  Future<Library?> build() async {
    final moduleBase = i.classInfo.module.base;
    final moduleClazz = i.classInfo.module.clazz;
    if (moduleBase == null) {
      return null;
    }

    final isWidget = i.classInfo.annotation.isWidget;

    final stateInterface = i.classInfo.state.interface;
    final stateBase = i.classInfo.state.base;
    final stateBaseTarget = i.classInfo.state.getNearBaseDeclaration();
    final stateClassTarget = i.classInfo.state.getNearClassDeclaration();

    final presenterInterface = i.classInfo.presenter.interface;
    final presenterBase = i.classInfo.presenter.base;
    if (presenterBase == null || presenterInterface == null) {
      return null;
    }

    final inputInterface = i.classInfo.input.interface;
    final inputTargetRef = i.classInfo.input.getNearInterfaceDeclaration()?.ref.unbound();

    final outputInterface = i.classInfo.output.interface;

    final viewBase = i.classInfo.view.base;
    final viewBaseTarget = i.classInfo.view.getNearBaseDeclaration();

    final interactorInterface = i.classInfo.interactor.interface;
    final interactorInterfaceTarget = i.classInfo.interactor.getNearInterfaceDeclaration();
    final interactorBase = i.classInfo.interactor.base;
    final interactorBaseTarget = i.classInfo.interactor.getNearBaseDeclaration();

    final routerInterface = i.classInfo.router.interface;
    final routerBase = i.classInfo.router.base;
    final routerBaseTarget = i.classInfo.router.getNearBaseDeclaration();

    final isFirstNavigator = i.classInfo.router.base?.base?.interface == null;

    final configurationBase = i.classInfo.configuration.base;
    if (configurationBase == null) {
      return null;
    }

    final interactorClassElement = interactorBase != null ? await getClassElementForExtendClass(interactorBase.base) : null;
    final stateClassElement = stateBase != null ? await getClassElementForExtendClass(stateBase.base) : null;
    final routerClassElement = routerBase != null ? await getClassElementForExtendClass(routerBase.base) : null;

    return Library((l) => l
      ..comments.addAll(["coverage: ignore-file", "ignore_for_file: type_init_formals, unnecessary_import"])
      ..directives.addAll([
        Directive((d) => d
          ..type = DirectiveType.export
          ..url = i.classInfo.contractsFileName),
      ])
      ..body.addAll([
        if (stateBase != null)
          Class((c) => c
            ..name = stateBase.ref.symbol
            ..abstract = true
            ..types.addAll(i.classInfo.genericParams)
            ..extend = stateBase.base?.ref.unbound()
            ..implements.addNotNull(stateBase.interface?.ref.unbound())
            ..constructors.addAllNotNull(stateClassElement?.constructors.toConstructorList())),
        if (interactorBase != null)
          Class((c) => c
            ..name = interactorBase.ref.symbol
            ..abstract = true
            ..types.addAll(interactorBase.ref.types)
            ..extend = interactorBase.base?.ref.unbound()
            ..implements.addNotNull(interactorBase.interface?.ref.unbound())
            ..constructors.addAllNotNull(interactorClassElement?.constructors.toConstructorList())),
        if (viewBase != null)
          Class((c) => c
            ..abstract = true
            ..name = viewBase.ref.symbol
            ..types.addAll(i.classInfo.genericParams)
            ..extend = viewBase.base?.ref.unbound()
            ..methods.addAll([
              Method((m) => m
                ..name = i.options.presenter.uncap
                ..type = MethodType.getter
                ..returns = presenterInterface.ref.unbound()
                ..annotations.add(overrideAnnotation)
                ..lambda = true
                ..body = Code("super.presenter as ${emitter.emitType(presenterInterface.ref.unbound())}")),
              if (stateInterface != null)
                Method((m) => m
                  ..name = i.options.state.uncap
                  ..type = MethodType.getter
                  ..returns = stateInterface.ref.unbound()
                  ..annotations.add(overrideAnnotation)
                  ..lambda = true
                  ..body = Code("super.state as ${emitter.emitType(stateInterface.ref.unbound())}")),
            ])),
        if (routerBase != null)
          Class((c) => c
            ..abstract = routerBase.isAbstract
            ..name = routerBase.ref.symbol
            ..types.addAll(i.classInfo.genericParams)
            ..extend = routerBase.base?.ref.unbound()
            ..implements.addNotNull(routerBase.interface?.ref.unbound())
            ..constructors.addAll([
              if (routerClassElement != null && routerBase.base?.interface != null) ...routerClassElement.constructors.toConstructorList(),
            ])
            ..methods.addAll([
              if (isFirstNavigator)
                Method((m) => m
                  ..name = "router"
                  ..returns = sviperRouterInterfaceReference.rebuild((t) => t..types.add(outputInterface?.ref.unbound() ?? voidReference))
                  ..type = MethodType.getter
                  ..annotations.add(overrideAnnotation))
            ])),
        Class((c) => c
          ..abstract = i.classInfo.annotation.hasPresenter
          ..name = presenterBase.ref.symbol
          ..types.addAll(presenterBase.ref.types)
          ..extend = presenterBase.base?.ref.unbound()
          ..implements.addNotNull(presenterBase.interface?.ref.unbound())
          ..constructors.addAll([
            Constructor((c) => c
              ..requiredParameters.add(Parameter((p) => p
                ..name = "configuration"
                ..type = configurationBase.ref.unbound()
                ..toSuper = true)))
          ])
          ..methods.addAll([
            if (inputInterface != null)
              Method((m) => m
                ..name = i.options.input.uncap
                ..type = MethodType.getter
                ..returns = inputInterface.ref.unbound()
                ..annotations.add(overrideAnnotation)
                ..lambda = true
                ..body = Code("super.input as ${emitter.emitType(inputInterface.ref.unbound())}")),
            if (stateClassTarget != null && stateInterface != null)
              Method((m) => m
                ..name = i.options.state.uncap
                ..type = MethodType.getter
                ..returns = stateClassTarget.ref.unbound()
                ..annotations.add(overrideAnnotation)
                ..lambda = true
                ..body = Code("super.state as ${emitter.emitType(stateClassTarget.ref.unbound())}")),
            if (interactorInterface != null)
              Method((m) => m
                ..name = i.options.interactor.uncap
                ..type = MethodType.getter
                ..returns = interactorInterface.ref.unbound()
                ..annotations.add(overrideAnnotation)
                ..lambda = true
                ..body = Code("super.interactor as ${emitter.emitType(interactorInterface.ref.unbound())}")),
            if (routerInterface != null)
              Method((m) => m
                ..name = i.options.router.uncap
                ..type = MethodType.getter
                ..returns = routerInterface.ref.unbound()
                ..annotations.add(overrideAnnotation)
                ..lambda = true
                ..body = Code("super.router as ${emitter.emitType(routerInterface.ref.unbound())}")),
          ])),
        Class((c) => c
          ..name = configurationBase.ref.symbol
          ..extend = configurationBase.base?.ref.unbound()
          ..types.addAll(i.classInfo.genericParams)
          ..constructors.add(Constructor((c) {
            final stateRequired = i.classInfo.state.getNearInterfaceDeclaration() != null;
            final inputRequired = i.classInfo.input.getNearInterfaceDeclaration() != null;
            final interactorRequired = i.classInfo.interactor.getNearInterfaceDeclaration() != null;
            final routerRequired = i.classInfo.router.getNearInterfaceDeclaration() != null;
            c.optionalParameters.addAll([
              Parameter((p) => p
                ..required = stateRequired
                ..name = "state"
                ..type = stateRequired ? i.classInfo.state.getNearClassDeclaration()?.ref.unbound() : null
                ..named = true
                ..toSuper = true),
              Parameter((p) => p
                ..required = inputRequired
                ..name = "input"
                ..type = inputRequired ? i.classInfo.input.getNearInterfaceDeclaration()?.ref.unbound() : null
                ..named = true
                ..toSuper = true),
              Parameter((p) => p
                ..required = interactorRequired
                ..name = "interactor"
                ..type = interactorRequired ? i.classInfo.interactor.getNearBaseDeclaration()?.ref.unbound() : null
                ..named = true
                ..toSuper = true),
              Parameter((p) => p
                ..required = routerRequired
                ..name = "router"
                ..type = routerRequired ? i.classInfo.router.getNearBaseDeclaration()?.ref.unbound() : null
                ..named = true
                ..toSuper = true),
            ]);
          }))),
        Class((c) => c
          ..abstract = true
          ..name = moduleBase.ref.symbol
          ..types.addAll(i.classInfo.genericParams)
          ..extend = moduleBase.base?.ref.unbound()
          ..implements.addNotNull(isWidget ? i.classInfo.input.getNearInterfaceDeclaration()?.ref.unbound() : null)
          ..constructors.add(Constructor((c) => c
            ..constant = true
            ..requiredParameters.addAll([
              if (!isWidget && inputTargetRef != null)
                Parameter((p) => p
                  ..name = i.options.input.uncap
                  ..type = i.classInfo.input.getNearInterfaceDeclaration()?.ref.unbound()
                  ..toSuper = true),
            ])
            ..optionalParameters.addAll([
              if (!isWidget)
                Parameter((p) => p
                  ..name = "name"
                  ..named = true
                  ..toSuper = true
                  ..defaultTo = moduleClazz == null ? null : Code('"${moduleClazz.ref.symbol}"')),
              Parameter((p) => p
                ..name = "key"
                ..named = true
                ..toSuper = true),
            ])
            ..initializers.addAll([if (!isWidget && inputTargetRef == null) const Code('super(const Object())')])))
          ..methods.addAll([
            if (i.classInfo.annotation.isWidget)
              Method((m) => m
                ..name = "getInput"
                ..returns = const Reference("Object")
                ..lambda = true
                ..annotations.add(overrideAnnotation)
                ..body = const Code("this")),
            if (inputTargetRef != null)
              Method((m) => m
                ..name = i.options.input.uncap
                ..returns = inputTargetRef
                ..type = MethodType.getter
                ..lambda = true
                ..body = Code(i.classInfo.annotation.isWidget ? "this" : "getInput() as ${emitter.emitType(inputTargetRef)}")),
            if (viewBaseTarget != null)
              Method((m) => m
                ..name = "build${i.options.view.cap}"
                ..annotations.add(overrideAnnotation)
                ..returns = viewBaseTarget.ref.unbound()),
            Method((m) => m
              ..name = "build${i.options.presenter.cap}"
              ..returns = presenterBase.ref.unbound()
              ..requiredParameters.add(Parameter((p) => p
                ..name = "configuration"
                ..type = configurationBase.ref.unbound()))),
            if (routerBaseTarget != null && routerBaseTarget.base != null)
              Method((m) => m
                ..name = "build${i.options.router.cap}"
                ..returns = routerBaseTarget.ref.unbound()
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "context"
                  ..type = buildContextReference))),
            if (stateClassTarget != null && stateClassTarget.base != null)
              Method((m) => m
                ..name = "build${i.options.state.cap}"
                ..returns = stateClassTarget.ref.unbound()
                ..requiredParameters.addAll([
                  if (interactorBaseTarget != null)
                    Parameter((p) => p
                      ..name = i.options.interactor.uncap
                      ..type = (interactorInterfaceTarget ?? interactorBaseTarget).ref.unbound())
                ])),
            if (interactorBaseTarget != null)
              Method((m) => m
                ..name = "build${i.options.interactor.cap}"
                ..returns = interactorBaseTarget.ref.unbound()
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "context"
                  ..type = buildContextReference))),
            if (viewBaseTarget != null)
              Method((m) => m
                ..name = "buildConfiguration"
                ..returns = sviperPresenterReference
                ..annotations.add(overrideAnnotation)
                ..requiredParameters.add(Parameter((p) => p
                  ..name = "view"
                  ..type = const Reference("SviperView")))
                ..body = Code("""
  ${interactorBaseTarget != null ? "final interactor = build${i.options.interactor.cap}(view.context);" : ""}
  final configuration = ${emitter.emitType(configurationBase.ref.unbound())}(
    state: ${stateBaseTarget != null ? "build${i.options.state.cap}(${interactorBaseTarget != null ? "interactor" : ""})" : "null"},
    input: ${inputTargetRef != null ? "input" : null},
    interactor: ${interactorBaseTarget != null ? "interactor" : "null"},
    router: ${routerBaseTarget != null ? "build${i.options.router.cap}(view.context)" : "null"},
  );
  return buildPresenter(configuration);
                """)),
          ]))
      ]));
  }

  @override
  FutureOr<String?>? fix(String contents) async {
    return buildLibrary(await build());
  }
}

extension ConstructorElementExt on List<ConstructorElement> {
  Iterable<Constructor> toConstructorList() => map((sc) => Constructor((c) => c
    ..name = sc.isDefaultConstructor || sc.name.isEmpty ? null : sc.name
    ..constant = sc.isConst
    ..requiredParameters.addAll(sc.parameters.where((it) => it.isPositional).map((sp) => Parameter((p) => p
      ..name = sp.name
      ..toSuper = true)))
    ..optionalParameters.addAll(sc.parameters.where((it) => !it.isPositional).map((sp) => Parameter((p) => p
      ..name = sp.name
      ..toSuper = true
      ..named = sp.isNamed
      ..required = sp.isRequired)))
    ..initializers.addAll([if (sc.name.isNotEmpty) Code("super.${sc.name}()")])));
}
