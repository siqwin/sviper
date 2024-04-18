import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';
import 'package:sviper_generator/src/builders/fixer/fixer.dart';
import 'package:sviper_generator/src/entities/class_info.dart';
import 'package:sviper_generator/src/entities/class_info_base.dart';
import 'package:sviper_generator/src/entities/constants.dart';

import 'package:sviper_generator/src/entities/generator_output.dart';
import 'package:sviper_generator/src/extensions/dart_emitter_extension.dart';
import 'package:sviper_generator/src/builders/base/builder_base.dart';

abstract class GeneratorClassBase extends GeneratorBase {
  GeneratorClassBase(super.i, {required super.classSuffix});

  Future<GeneratorOutput?> generate() async {
    final file = File(targetClassInfo.absoluteFilePath);
    final currentCode = file.existsSync() ? file.readAsStringSync() : null;
    if (currentCode?.contains("${codename}_disable") == true) {
      return null;
    }
    final resultCode = currentCode == null ? buildLibrary(await build()) : await fix(currentCode);
    if (resultCode != null && resultCode != currentCode) {
      final formattedCode = formatCode(resultCode);
      if (formattedCode == null) {
        return null;
      }
      return GeneratorOutput(file, resultCode, isBuildStepResult);
    }
    return null;
  }

  FutureOr<cb.Library?> build() => cb.Library();

  FutureOr<String?>? fix(String contents) async {
    final library = await build();
    if (library == null) {
      return null;
    }

    final emittedCode = emitter.emitLibrary(library);
    final libraryElement = await i.resolver.getLibraryElement(targetClassInfo);
    final parsed = libraryElement?.session.getParsedLibraryByElement(libraryElement);
    if (parsed is ParsedLibraryResult && parsed.units.isNotEmpty && libraryElement != null) {
      final assetId = AssetId.parse("${i.classInfo.packageName}|${i.classInfo.packagePath}/${i.classInfo.className}$classSuffix.temp.dart");
      final sourceUnit = parsed.units.first.unit;
      try {
        final targetUnit = await resolveSources({assetId.toString(): emittedCode}, (r) {
          return r.compilationUnitFor(assetId);
        });
        final fixer = Fixer(
          source: sourceUnit,
          target: targetUnit,
          formatter: formatCode,
        );
        var fixList = fixer.getFixList();
        if (fixList.isNotEmpty) {
          fixList = fixList.indexed
              .sorted((a, b) {
                var cmp = b.$2.offset.compareTo(a.$2.offset);
                if (cmp == 0) {
                  cmp = a.$2.priority.compareTo(b.$2.priority);
                  if (cmp == 0) {
                    return b.$1.compareTo(a.$1);
                  }
                }
                return cmp;
              })
              .map((e) => e.$2)
              .toList();

          String targetContent = contents;
          for (final fix in fixList) {
            targetContent = targetContent.replaceRange(fix.offset, fix.offset + fix.length, fix.replace);
          }
          return targetContent;
        }
      } catch (error) {
        // ignore: avoid_print
        print("Failed to parse code:\n$emittedCode");
      }
    }
    return null;
  }

  Future<ClassElement?> getClassElementForExtendClassDescription(ClassInfo classInfo, String suffix) async {
    final extendClassDescription = ClassCommonInfo(
      className: "${classInfo.className}$suffix",
      packageName: classInfo.packageName,
      packagePath: classInfo.packagePath,
      fileName: classInfo.prepareFileName("${classInfo.fileName}$suffix"),
      fileDir: classInfo.fileDir,
    );
    final libraryElement = await i.resolver.getLibraryElement(extendClassDescription);
    return libraryElement?.getClass(extendClassDescription.className);
  }

  Future<ClassElement?> getClassElementForExtendClass(ClassDeclaration? clazz) async {
    if (clazz == null) {
      return null;
    }
    final libraryElement = await i.resolver.getLibraryElementByReference(clazz.ref);
    return getClassFromLibrary(libraryElement, clazz.ref.symbol);
  }

  ClassElement? getClassFromLibrary(LibraryElement? libraryElement, String className) {
    if (libraryElement == null) {
      return null;
    }
    ClassElement? classElement = libraryElement.getClass(className);
    if (classElement != null) {
      return classElement;
    } else {
      for (final exportLibrary in libraryElement.libraryExports) {
        classElement = getClassFromLibrary(exportLibrary.exportedLibrary, className);
        if (classElement != null) {
          return classElement;
        }
      }
    }
    return null;
  }
}
