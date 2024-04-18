import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/entities/class_info.dart';
import 'package:sviper_generator/src/extensions/code_builder_extension.dart';
import 'package:sviper_generator/src/entities/constants.dart';

class ClassDeclaration {
  final bool isAbstract;
  final TypeReference ref;
  final ClassDeclaration? base;
  final ClassDeclaration? interface;

  ClassDeclaration({
    required this.ref,
    this.isAbstract = false,
    this.base,
    this.interface,
  });

  List<TypeReference> getSuperInterfaceList({bool unbound = true}) {
    final result = <TypeReference>[];
    ClassDeclaration? cur = interface;
    while (true) {
      if (cur == null) {
        break;
      }
      final curRef = cur.ref;
      result.add(unbound == true ? curRef.unbound() : curRef);
      cur = cur.interface;
    }
    return result;
  }
}

class ClassInfoBase {
  ClassDeclaration? getNearClassDeclaration() {
    ClassInfoBase? cur = this;
    while (true) {
      if (cur == null) {
        return null;
      }
      final curClass = cur.clazz;
      if (curClass != null) {
        return curClass;
      }
      cur = cur.parent;
    }
  }

  ClassDeclaration? getNearInterfaceDeclaration() {
    ClassInfoBase? cur = this;
    while (true) {
      if (cur == null) {
        return null;
      }
      final curClass = cur.interface;
      if (curClass != null) {
        return curClass;
      }
      cur = cur.parent;
    }
  }

  ClassDeclaration? getNearBaseDeclaration() {
    ClassInfoBase? cur = this;
    while (true) {
      if (cur == null) {
        return null;
      }
      final curClass = cur.base;
      if (curClass != null) {
        return curClass;
      }
      cur = cur.parent;
    }
  }

  ClassInfoBase? getNearClassInfo() {
    ClassInfoBase? cur = this;
    while (true) {
      if (cur == null) {
        return null;
      }
      if (cur.clazz != null) {
        return cur;
      }
      cur = cur.parent;
    }
  }

  List<TypeReference> getInterfaceList({bool unbound = true}) {
    final result = <TypeReference>[];
    ClassDeclaration? cur = getNearClassDeclaration()?.interface;
    while (true) {
      if (cur == null) {
        break;
      }
      final curRef = cur.ref;
      result.add(unbound == true ? curRef.unbound() : curRef);
      cur = cur.interface;
    }
    return result;
  }

  final ClassDeclaration? clazz;
  final ClassDeclaration? base;
  final ClassDeclaration? interface;
  final ClassInfoBase? parent;

  ClassInfoBase({
    this.clazz,
    ClassDeclaration? base,
    ClassDeclaration? interface,
    this.parent,
  })  : base = base ?? clazz?.base,
        interface = interface ?? clazz?.interface;

  factory ClassInfoBase.full({
    required ClassInfo classInfo,
    required String name,
    ClassInfoBase? parent,
    bool hasBase = true,
    bool hasClass = true,
    bool hasInterface = true,
  }) {
    final interface = hasInterface
        ? ClassDeclaration(
            isAbstract: true,
            ref: TypeReference(
              (t) => t
                ..symbol = "${classInfo.options.prefix}${classInfo.className}$name${classInfo.options.suffix}"
                ..url = classInfo.contractsFileName
                ..types.addAll(classInfo.genericParams),
            ),
            interface: parent?.getNearInterfaceDeclaration(),
          )
        : null;
    final base = hasBase
        ? ClassDeclaration(
            isAbstract: true,
            ref: TypeReference(
              (t) => t
                ..symbol = "${classInfo.options.prefixBase}${classInfo.className}$name${classInfo.options.suffixBase}"
                ..url = classInfo.genFileName
                ..types.addAll(classInfo.genericParams),
            ),
            base: parent?.getNearClassDeclaration(),
            interface: interface)
        : null;
    final clazz = hasClass
        ? ClassDeclaration(
            ref: TypeReference(
              (t) => t
                ..symbol = "${classInfo.className}$name"
                ..url = classInfo.toAbsolutePackagePath(classInfo.prepareFileName("${classInfo.fileName}$name.dart"))
                ..types.addAll(classInfo.genericParams),
            ),
            base: base,
            interface: interface,
            isAbstract: false,
          )
        : null;
    return ClassInfoBase(
      clazz: clazz,
      base: base,
      interface: interface,
      parent: parent,
    );
  }

  factory ClassInfoBase.module(ClassInfo classInfo) {
    return ClassInfoBase.full(
      classInfo: classInfo,
      name: classInfo.options.module,
      hasInterface: false,
      parent: ClassInfoBase(
        clazz: ClassDeclaration(
          ref: classInfo.annotation.isWidget ? sviperWidgetReference : sviperPageReference.rebuild((t) => t..types.add(classInfo.output.getNearInterfaceDeclaration()?.ref ?? voidReference)),
        ),
      ),
    );
  }

  factory ClassInfoBase.input(ClassInfo classInfo) {
    final hasInput = classInfo.annotation.hasInput;
    final parent = classInfo.extendsClassInfo?.input;
    if (hasInput) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.input,
        parent: parent,
        hasBase: false,
        hasClass: !classInfo.annotation.isWidget,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.output(ClassInfo classInfo) {
    final hasOutput = classInfo.annotation.hasOutput;
    final parent = classInfo.extendsClassInfo?.output;
    if (hasOutput) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.output,
        parent: parent,
        hasBase: false,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.configuration(ClassInfo classInfo) {
    return ClassInfoBase(
      base: ClassDeclaration(
        ref: TypeReference((t) => t
          ..symbol = "${classInfo.className}${classInfo.options.configuration}"
          ..types.addAll(classInfo.genericParams)
          ..url = classInfo.genFileName),
        base: classInfo.extendsClassInfo?.configuration.base ?? ClassDeclaration(ref: sviperConfigurationReference),
      ),
      parent: classInfo.extendsClassInfo?.configuration,
    );
  }

  factory ClassInfoBase.view(ClassInfo classInfo) {
    final hasView = classInfo.annotation.hasView;
    final parent = classInfo.extendsClassInfo?.view ?? ClassInfoBase(clazz: ClassDeclaration(ref: sviperViewReference));
    if (hasView) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.view,
        parent: parent,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.state(ClassInfo classInfo) {
    final hasState = classInfo.annotation.hasState;
    final parent = classInfo.extendsClassInfo?.state ?? ClassInfoBase(clazz: ClassDeclaration(ref: sviperStateReference));
    if (hasState) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.state,
        parent: parent,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.presenter(ClassInfo classInfo) {
    final hasPresenter = classInfo.annotation.hasPresenter;
    final parent = classInfo.extendsClassInfo?.presenter ?? ClassInfoBase(clazz: ClassDeclaration(ref: sviperPresenterReference));
    if (hasPresenter) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.presenter,
        parent: parent,
      );
    } else {
      return ClassInfoBase(
        base: ClassDeclaration(
          isAbstract: false,
          ref: TypeReference(
            (t) => t
              ..symbol = "${classInfo.options.prefixBase}${classInfo.className}${classInfo.options.presenter}${classInfo.options.suffixBase}"
              ..url = classInfo.genFileName
              ..types.addAll(classInfo.genericParams),
          ),
          base: parent.getNearClassDeclaration(),
          interface: null,
        ),
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.interactor(ClassInfo classInfo) {
    final hasInteractor = classInfo.annotation.hasInteractor;
    final parent = classInfo.extendsClassInfo?.interactor ?? ClassInfoBase(clazz: ClassDeclaration(ref: sviperInteractorReference));
    if (hasInteractor) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.interactor,
        parent: parent,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }

  factory ClassInfoBase.router(ClassInfo classInfo) {
    final hasRouter = classInfo.annotation.hasRouter;
    final parent = classInfo.extendsClassInfo?.router ?? ClassInfoBase(clazz: ClassDeclaration(ref: sviperRouterReference));
    if (hasRouter) {
      return ClassInfoBase.full(
        classInfo: classInfo,
        name: classInfo.options.router,
        parent: parent,
      );
    } else {
      return ClassInfoBase(
        clazz: null,
        parent: parent,
      );
    }
  }
}
