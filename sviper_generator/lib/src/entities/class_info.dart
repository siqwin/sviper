import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

import 'package:sviper_generator/src/entities/class_info_base.dart';
import 'package:sviper_generator/src/extensions/string_extension.dart';
import 'package:sviper_generator/src/entities/constants.dart';
import 'package:sviper_generator/src/entities/filename_case_type.dart';
import 'package:sviper_generator/src/entities/generator_options.dart';
import 'package:sviper_generator/src/utils/type_infer_utils.dart';
import 'package:sviper_generator/src/entities/generator_annotation.dart';

class ClassCommonInfo {
  final String packageName;
  final String packagePath;
  final String className;
  final String fileName;
  final String fileDir;

  ClassCommonInfo({
    required this.packageName,
    required this.packagePath,
    required this.className,
    required this.fileName,
    required this.fileDir,
  });
}

extension ClassCommonInfoExtension on ClassCommonInfo {
  String get absolutePackagePath => "$packageName/$packagePath";

  String get absoluteFilePath => join(fileDir, "$fileName.dart");
}

class ClassInfo implements ClassCommonInfo {
  @override
  final String className;
  @override
  final String packageName;
  @override
  final String packagePath;
  @override
  final String fileName;
  @override
  final String fileDir;

  late final String contractsFileName;
  late final String genFileName;

  ClassInfo? extendsClassInfo;
  final List<Reference> genericParams;
  final GeneratorAnnotation annotation;
  final GeneratorOptions options;

  late final ClassInfoBase input;
  late final ClassInfoBase output;

  late final ClassInfoBase view;
  late final ClassInfoBase state;
  late final ClassInfoBase presenter;
  late final ClassInfoBase interactor;
  late final ClassInfoBase router;

  late final ClassInfoBase configuration;

  late final ClassInfoBase module;
  late final FileNameCaseType fileNameCase;

  ClassInfo({
    required this.extendsClassInfo,
    required this.options,
    required this.className,
    required this.genericParams,
    required this.annotation,
    required this.packageName,
    required this.packagePath,
    required this.fileName,
    required this.fileDir,
  }) {
    fileNameCase = FileNameCaseType.parseByFileName(fileName);

    contractsFileName = toAbsolutePackagePath(prepareFileName("$fileName${options.contracts}.dart"));
    genFileName = toAbsolutePackagePath(prepareFileName("$fileName${options.module}.$codename.dart"));

    input = ClassInfoBase.input(this);
    output = ClassInfoBase.output(this);

    view = ClassInfoBase.view(this);
    state = ClassInfoBase.state(this);
    presenter = ClassInfoBase.presenter(this);
    interactor = ClassInfoBase.interactor(this);
    router = ClassInfoBase.router(this);

    configuration = ClassInfoBase.configuration(this);

    module = ClassInfoBase.module(this);
  }

  factory ClassInfo.fromElementAnnotation(ClassElement classElement, GeneratorAnnotation annotation, GeneratorOptions options, [List<Reference>? parentGenericParams]) {
    final className = classElement.name;
    final currentGenericParams = TypeInferUtils.getTypeParameterElement(classElement.typeParameters, parentGenericParams);
    final genericParams = currentGenericParams;

    final absolutePackagePathSegments = classElement.source.uri.pathSegments;
    final packageName = absolutePackagePathSegments.first;
    final packagePath = List<String>.from(absolutePackagePathSegments).sublist(1, absolutePackagePathSegments.length - 1).join("/");

    final sourceFilePath = classElement.source.fullName;
    final file = File(sourceFilePath.startsWith("/$packageName/") ? sourceFilePath.replaceFirst("/$packageName/", "") : sourceFilePath);
    final absoluteFileUri = file.absolute.uri.normalizePath();
    final fileName = absoluteFileUri.pathSegments.last.withoutExtension();
    final absoluteDirectory = file.parent.path;

    final extendClassType = annotation.extendsType;
    final extendClassElement = extendClassType?.element;
    ClassInfo? extendsClassInfo;



    if (extendClassElement != null) {
      final extendClassAnnotation = extendClassElement.metadata.firstWhereOrNull((element) => element.toString().contains("@Sviper"));
      if (extendClassElement is ClassElement && extendClassAnnotation != null) {
        final annotationReader = ConstantReader(extendClassAnnotation.computeConstantValue());
        if (extendClassType is InterfaceType && extendClassType.typeArguments.isNotEmpty) {
          extendsClassInfo = ClassInfo.fromElementAnnotation(extendClassElement, GeneratorAnnotation.fromAnnotation(annotationReader), options, extendClassType.typeArguments.map((e) {
            return TypeReference((t) => t
              ..symbol = e.getDisplayString(withNullability: false)
              ..url = TypeInferUtils.getPackageUrlForType(classElement, e)
            );
          }).toList());
        } else if (genericParams.length != extendClassElement.typeParameters.length) {
          // TODO check bound
          throw InvalidGenerationSourceError("Extend class have different generic params", element: classElement);
        } else {
          extendsClassInfo = ClassInfo.fromElementAnnotation(extendClassElement, GeneratorAnnotation.fromAnnotation(annotationReader), options, genericParams);
        }
      } else {
        throw InvalidGenerationSourceError("Extend class type must have @Sviper annotation", element: classElement);
      }
    }

    return ClassInfo(
      className: className,
      genericParams: genericParams,
      annotation: annotation,
      packagePath: packagePath,
      packageName: packageName,
      fileName: fileName,
      fileDir: absoluteDirectory,
      options: options,
      extendsClassInfo: extendsClassInfo,
    );
  }

  @override
  String toString() => jsonEncode({"className": className, "packageName": packageName, "packagePath": packagePath, "fileName": fileName, "fileDir": fileDir});

  String prepareFileName(String name) {
    String targetName = name;
    String ext = "";
    final dotIndex = targetName.indexOf(".");
    if (dotIndex > 0) {
      ext = targetName.substring(dotIndex);
      targetName = targetName.substring(0, dotIndex);
    }
    switch (fileNameCase) {
      case FileNameCaseType.pascal:
        return "${targetName.pascalCase}$ext";
      case FileNameCaseType.camel:
        return "${targetName.camelCase}$ext";
      case FileNameCaseType.snake:
        return "${targetName.snakeCase}$ext";
    }
  }

  String toAbsolutePackagePath(String name) {
    return "package:$absolutePackagePath/$name";
  }
}
