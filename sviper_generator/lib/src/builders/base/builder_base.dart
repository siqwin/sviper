import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'package:sviper_generator/src/extensions/dart_emitter_extension.dart';
import 'package:sviper_generator/src/entities/module_description.dart';
import 'package:sviper_generator/src/entities/class_info.dart';


final _codeFormatter = DartFormatter(pageWidth: 200, languageVersion: DartFormatter.latestLanguageVersion);

abstract class GeneratorBase {
  late final DartEmitter emitter;
  final ModuleDescription i;
  final ClassCommonInfo targetClassInfo;

  bool get isBuildStepResult => false;

  final String classSuffix;

  GeneratorBase(this.i, {required this.classSuffix})
      : targetClassInfo = ClassCommonInfo(
          packageName: i.classInfo.packageName,
          packagePath: i.classInfo.packagePath,
          fileName: i.classInfo.prepareFileName("${i.classInfo.fileName}$classSuffix"),
          fileDir: i.classInfo.fileDir,
          className: "${i.classInfo.className}$classSuffix",
        ) {
    emitter = DartEmitter(
      allocator: _CustomAllocator(["package:${targetClassInfo.absolutePackagePath}/${targetClassInfo.fileName}.dart"]),
      useNullSafetySyntax: true,
      orderDirectives: true,
    );
  }

  String? buildLibrary(Library? library) {
    if (library == null || library.body.isEmpty) {
      return null;
    }
    return formatCode(emitter.emitLibrary(library));
  }

  String? formatCode(String code) {
    try {
      return _codeFormatter.format(code);
    } catch (error) {
      // ignore: avoid_print
      print("Failed to format code: \n$code");
      return null;
    }
  }
}

class _CustomAllocator implements Allocator {
  final _imports = <String>{};
  final List<String> _ignoreImports;

  _CustomAllocator(this._ignoreImports);

  @override
  String allocate(Reference reference) {
    final url = reference.url;
    if (url != null && !_ignoreImports.contains(url)) {
      _imports.add(url);
    }
    return reference.symbol!;
  }

  @override
  Iterable<Directive> get imports => _imports.map(Directive.import);
}
