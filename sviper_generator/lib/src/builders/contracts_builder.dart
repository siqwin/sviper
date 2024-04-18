import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/builders/base/builder_class_base.dart';

class ContractsBuilder extends GeneratorClassBase {
  ContractsBuilder(super.i) : super(classSuffix: i.options.contracts);

  @override
  Library build() {
    final inputInterface = i.classInfo.input.interface;
    final outputInterface = i.classInfo.output.interface;
    final stateInterface = i.classInfo.state.interface;
    final presenterInterface = i.classInfo.presenter.interface;
    final interactorInterface = i.classInfo.interactor.interface;
    final routerInterface = i.classInfo.router.interface;
    return Library((l) => l
      ..body.addAll([
        if (inputInterface != null)
          Class((c) => c
            ..name = inputInterface.ref.symbol
            ..types.addAll(inputInterface.ref.types)
            ..implements.addAll(inputInterface.getSuperInterfaceList())
            ..abstract = inputInterface.isAbstract),
        if (outputInterface != null)
          Class((c) => c
            ..name = outputInterface.ref.symbol
            ..types.addAll(outputInterface.ref.types)
            ..implements.addAll(outputInterface.getSuperInterfaceList())
            ..abstract = outputInterface.isAbstract),
        if (stateInterface != null)
          Class((c) => c
            ..name = stateInterface.ref.symbol
            ..types.addAll(stateInterface.ref.types)
            ..implements.addAll(stateInterface.getSuperInterfaceList())
            ..abstract = stateInterface.isAbstract),
        if (presenterInterface != null)
          Class((c) => c
            ..name = presenterInterface.ref.symbol
            ..types.addAll(presenterInterface.ref.types)
            ..implements.addAll(presenterInterface.getSuperInterfaceList())
            ..abstract = presenterInterface.isAbstract),
        if (interactorInterface != null)
          Class((c) => c
            ..name = interactorInterface.ref.symbol
            ..types.addAll(interactorInterface.ref.types)
            ..implements.addAll(interactorInterface.getSuperInterfaceList())
            ..abstract = interactorInterface.isAbstract),
        if (routerInterface != null)
          Class((c) => c
            ..name = routerInterface.ref.symbol
            ..types.addAll(routerInterface.ref.types)
            ..implements.addAll(routerInterface.getSuperInterfaceList())
            ..abstract = routerInterface.isAbstract),
      ]));
  }
}
