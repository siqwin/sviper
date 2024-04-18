import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sviper/sviper.dart';
import 'package:sviper_generator/src/entities/class_info.dart';
import 'package:sviper_generator/src/entities/generator_annotation.dart';

import 'package:sviper_generator/src/builders/contracts_base_builder.dart';
import 'package:sviper_generator/src/builders/contracts_builder.dart';
import 'package:sviper_generator/src/builders/input_builder.dart';
import 'package:sviper_generator/src/builders/interactor_builder.dart';
import 'package:sviper_generator/src/builders/module_builder.dart';
import 'package:sviper_generator/src/builders/output_builder.dart';
import 'package:sviper_generator/src/builders/presenter_builder.dart';
import 'package:sviper_generator/src/builders/router_builder.dart';
import 'package:sviper_generator/src/builders/state_builder.dart';
import 'package:sviper_generator/src/builders/view_builder.dart';

import 'package:sviper_generator/src/entities/generator_options.dart';
import 'package:sviper_generator/src/entities/module_description.dart';

import 'package:sviper_generator/src/resolvers/build_step_resolver.dart';

class SviperGenerator extends GeneratorForAnnotation<Sviper> {
  final GeneratorOptions options;

  SviperGenerator(this.options);

  @override
  Future<dynamic> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError("@Sviper can only be applied on classes. Failing element: '${element.name}' at '${buildStep.inputId.path}'", element: element);
    }

    final classInfo = ClassInfo.fromElementAnnotation(element, GeneratorAnnotation.fromAnnotation(annotation), options);
    final moduleDescription = ModuleDescription(
      options: options,
      classInfo: classInfo,
      resolver: BuildStepResolver(buildStep),
    );

    return build(moduleDescription);
  }

  static Future<String?> build(ModuleDescription module) async {
    await module.resolver.build(InputBuilder(module).generate());
    await module.resolver.build(OutputBuilder(module).generate());
    await module.resolver.build(ViewBuilder(module).generate());
    await module.resolver.build(StateBuilder(module).generate());
    await module.resolver.build(PresenterBuilder(module).generate());
    await module.resolver.build(InteractorBuilder(module).generate());
    await module.resolver.build(RouterBuilder(module).generate());
    await module.resolver.build(ContractsBuilder(module).generate());
    await module.resolver.build(ModuleBuilder(module).generate());
    await module.resolver.build(ContractsBaseBuilder(module).generate());
    return module.resolver.result;
  }
}
