import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/entities/generator_output.dart';
import 'package:sviper_generator/src/extensions/directory_extension.dart';

import 'package:sviper_generator/src/entities/class_info.dart';

abstract class ResolverBase {
  String? result;

  Future<LibraryElement?> getLibraryElement(ClassCommonInfo classInfo);

  Future<void> build(Future<GeneratorOutput?> generate) async {
    final output = await generate;
    if (output != null) {
      output.file.parent.createSyncIfNotExists();
      output.file.writeAsStringSync(output.code);
    }
  }

  Future<LibraryElement?> getLibraryElementByReference(TypeReference ref);
}
