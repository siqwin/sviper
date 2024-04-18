import 'package:code_builder/code_builder.dart';

const codename = "sviper";
const sviperModulePackage = "package:sviper/sviper_module.dart";

const overrideAnnotation = Reference("override");

const materialPackage = "package:flutter/material.dart";
const widgetType = Reference("Widget", materialPackage);
const buildContextReference = Reference("BuildContext", materialPackage);
final voidReference = TypeReference((t) => t..symbol = "void");


final sviperStateReference = TypeReference(
  (t) => t
    ..symbol = "SviperState"
    ..url = sviperModulePackage,
);
final sviperInteractorReference = TypeReference(
  (t) => t
    ..symbol = "SviperInteractor"
    ..url = sviperModulePackage,
);
final sviperViewReference = TypeReference(
  (t) => t
    ..symbol = "SviperView"
    ..url = sviperModulePackage,
);
final sviperRouterReference = TypeReference(
  (t) => t
    ..symbol = "SviperRouter"
    ..url = sviperModulePackage,
);
final sviperRouterInterfaceReference = TypeReference(
  (t) => t
    ..symbol = "ISviperRouter"
    ..url = sviperModulePackage,
);
final sviperPresenterReference = TypeReference(
  (t) => t
    ..symbol = "SviperPresenter"
    ..url = sviperModulePackage,
);
final sviperConfigurationReference = TypeReference(
  (t) => t
    ..symbol = "SviperConfiguration"
    ..url = sviperModulePackage,
);
final sviperWidgetReference = TypeReference(
  (t) => t
    ..symbol = "SviperWidget"
    ..url = sviperModulePackage,
);
final sviperPageReference = TypeReference(
  (t) => t
    ..symbol = "SviperPage"
    ..url = sviperModulePackage,
);
