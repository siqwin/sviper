import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';

import 'package:sviper_generator/src/entities/generator_output.dart';
import 'package:sviper_generator/src/entities/class_info.dart';
import 'package:sviper_generator/src/resolvers/resolver.dart';

class BuildStepResolver extends ResolverBase {
  final BuildStep buildStep;

  BuildStepResolver(this.buildStep);

  @override
  Future<LibraryElement> getLibraryElement(ClassCommonInfo classInfo) {
    final assetId = AssetId.resolve(Uri.parse("package:${classInfo.packageName}/${classInfo.packagePath}/${classInfo.fileName}.dart"));
    return buildStep.resolver.libraryFor(assetId);
  }

  @override
  Future<LibraryElement?> getLibraryElementByReference(TypeReference ref) async {
    final url = ref.url;
    if (url == null) {
      return null;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    final assetId = AssetId.resolve(uri);
    return buildStep.resolver.libraryFor(assetId);
  }

  @override
  Future<void> build(Future<GeneratorOutput?> generate) async {
    final output = await generate;
    if (output != null) {
      if (output.isBuildStepResult) {
        result = output.code;
      } else {
        await super.build(generate);
      }
    }
  }
}
