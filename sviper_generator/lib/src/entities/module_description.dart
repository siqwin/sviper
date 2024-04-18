import 'package:sviper_generator/src/entities/class_info.dart';

import 'package:sviper_generator/src/resolvers/resolver.dart';
import 'package:sviper_generator/src/entities/generator_options.dart';

class ModuleDescription {
  final ClassInfo classInfo;
  final ResolverBase resolver;
  final GeneratorOptions options;

  ModuleDescription({
    required this.classInfo,
    required this.resolver,
    required this.options,
  });
}
