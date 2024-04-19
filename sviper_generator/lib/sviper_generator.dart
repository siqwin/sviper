library sviper_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:sviper_generator/src/entities/generator_options.dart';
import 'package:sviper_generator/src/sviper_generator.dart';

/// Creates a [Builder] for [SviperGenerator].
Builder createSviperBuilder([BuilderOptions? options]) {
  final generatorOptions = GeneratorOptions(options?.config ?? {});
  return LibraryBuilder(
    SviperGenerator(generatorOptions),
    generatedExtension: ".sviper.dart",
    allowSyntaxErrors: true,
    formatOutput: (v) => v,
    options: options,
  );
}
