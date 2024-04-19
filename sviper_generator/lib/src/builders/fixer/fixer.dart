import 'package:collection/collection.dart';
import 'package:analyzer/dart/ast/ast.dart';

class FixInfo {
  final int offset;
  final int length;
  final String replace;
  final int priority;

  FixInfo({
    required this.offset,
    required this.length,
    required this.replace,
    this.priority = 0,
  });
}

class Fixer {
  final CompilationUnit source;
  final CompilationUnit target;
  final List<FixInfo> fixList = [];
  final String? Function(String) formatter;
  final List<String> addImports = [];

  Fixer({
    required this.source,
    required this.target,
    required this.formatter,
  });

  List<FixInfo> getFixList() {
    compareAbsoluteDirectivesList(target.directives, source.directives);
    compareDirectivesList(target.directives, source.directives, (it) => it.contains(".sviper.dart"));
    for (final targetDeclaration in target.declarations) {
      if (targetDeclaration is ClassDeclaration) {
        final sourceDeclaration = source.declarations.firstWhereOrNull((element) => element is ClassDeclaration && element.name.lexeme == targetDeclaration.name.lexeme) as ClassDeclaration?;
        compareClassDeclaration(sourceDeclaration, targetDeclaration);
      }
    }
    return fixList;
  }

  void compareClassDeclaration(ClassDeclaration? sourceDeclaration, ClassDeclaration targetDeclaration) {
    if (sourceDeclaration != null) {
      _compareExtends(sourceDeclaration, sourceDeclaration.extendsClause, targetDeclaration.extendsClause);
      _compareImplements(sourceDeclaration, sourceDeclaration.implementsClause, targetDeclaration.implementsClause);
      _compareTypedParameters(sourceDeclaration, sourceDeclaration.typeParameters, targetDeclaration.typeParameters);
      _compareMembers(sourceDeclaration, sourceDeclaration.members, targetDeclaration.members);
      _compareConstructors(sourceDeclaration, sourceDeclaration.members.whereType<ConstructorDeclaration>().toList(), targetDeclaration.members.whereType<ConstructorDeclaration>().toList());
    } else {
      compareDirectivesList(target.directives, source.directives);
      fixList.add(FixInfo(
        offset: source.end,
        length: 0,
        replace: "\n${formatter(targetDeclaration.toSource())}",
      ));
    }
  }

  void _compareConstructors(ClassDeclaration sourceDeclaration, List<ConstructorDeclaration> sourceConstructorDeclarations, List<ConstructorDeclaration> targetConstructorDeclarations) {
    for (final targetConstructorDeclaration in targetConstructorDeclarations) {
      final sourceConstructorDeclaration = sourceConstructorDeclarations.firstWhereOrNull((element) {
        return element.name?.stringValue == targetConstructorDeclaration.name?.stringValue;
      });

      if (sourceConstructorDeclaration == null) {
        if (sourceDeclaration.abstractKeyword != null) {
          continue;
        }
        fixList.add(FixInfo(
          offset: sourceDeclaration.leftBracket.end,
          length: 0,
          replace: "\n${_ident(targetConstructorDeclaration.toSource(), 2)}",
          priority: 10,
        ));
      }
    }
  }

  int? calcDirectiveOffset(Directive directive, NodeList<Directive> currentDirectives) {
    if (currentDirectives.isEmpty) {
      return 0;
    }

    final firstDirective = currentDirectives.first;
    final lastDirective = currentDirectives.last;
    final lastImportDirective = currentDirectives.lastWhereOrNull((it) => it is ImportDirective);
    final lastExportDirective = currentDirectives.lastWhereOrNull((it) => it is ExportDirective);
    final lastPartDirective = currentDirectives.lastWhereOrNull((it) => it is PartDirective);

    if (directive is ImportDirective) {
      final res = lastImportDirective ?? firstDirective;
      return res.offset + res.length;
    } else if (directive is ExportDirective) {
      final res = lastExportDirective ?? lastImportDirective;
      if (res == null) {
        return 0;
      }
      return res.offset + res.length;
    } else if (directive is PartDirective) {
      final res = lastPartDirective ?? lastDirective;
      return res.offset + res.length;
    }
    return null;
  }

  void compareDirectivesList(NodeList<Directive> targetDirectives, NodeList<Directive> currentDirectives, [bool Function(String)? test]) {
    for (final targetDirective in targetDirectives) {
      if (targetDirective is UriBasedDirective) {
        final targetUri = targetDirective.uri.stringValue;
        if (targetUri != null) {
          final sourceUri = currentDirectives.firstWhereOrNull((element) {
            if (element is UriBasedDirective) {
              final sourceUri = element.uri.stringValue;
              if (sourceUri != null) {
                return targetUri.contains(sourceUri) || sourceUri.contains(targetUri);
              }
            }
            return false;
          });
          if (sourceUri == null) {
            final offset = calcDirectiveOffset(targetDirective, currentDirectives);
            final targetDirectiveSource = targetDirective.toSource();
            if (offset != null && !addImports.contains(targetDirectiveSource)) {
              addImports.add(targetDirectiveSource);
              fixList.add(FixInfo(
                offset: offset,
                length: 0,
                replace: "\n$targetDirectiveSource",
                priority: -1,
              ));
            }
          }
        }
      }
    }
  }

  void compareAbsoluteDirectivesList(NodeList<Directive> targetDirectives, NodeList<Directive> currentDirectives) {
    for (final targetDirective in targetDirectives) {
      if (targetDirective is UriBasedDirective) {
        final targetUri = targetDirective.uri.stringValue;
        if (targetUri != null) {
          final sourceUri = currentDirectives.firstWhereOrNull((element) {
            if (element is UriBasedDirective) {
              final sourceUri = element.uri.stringValue;
              if (sourceUri != null && sourceUri.runtimeType == targetUri.runtimeType && sourceUri != targetUri && targetUri.contains(sourceUri)) {
                return true;
              }
            }
            return false;
          });
          if (sourceUri != null && !addImports.contains(sourceUri.toSource())) {
            final targetDirectiveSource = sourceUri.toSource();
            addImports.add(targetDirectiveSource);
            fixList.add(FixInfo(
              offset: sourceUri.offset,
              length: sourceUri.length,
              replace: targetDirectiveSource,
              priority: -1,
            ));
          }
        }
      }
    }
  }

  void _compareExtends(ClassDeclaration currentClassDeclaration, ExtendsClause? currentExtendsClause, ExtendsClause? targetExtendsClause) {
    if (currentExtendsClause == null && targetExtendsClause != null) {
      final offset = currentClassDeclaration.typeParameters?.rightBracket.end ?? currentClassDeclaration.name.end;
      fixList.add(FixInfo(
        offset: offset,
        length: 0,
        replace: " ${targetExtendsClause.toSource()}",
      ));
    } else if (currentExtendsClause != null && targetExtendsClause != null) {
      if (currentExtendsClause.toSource() != targetExtendsClause.toSource()) {
        fixList.add(FixInfo(
          offset: currentExtendsClause.offset,
          length: currentExtendsClause.length,
          replace: targetExtendsClause.toSource(),
        ));
      }
    }
  }

  void _compareImplements(ClassDeclaration currentClassDeclaration, ImplementsClause? currentImplementsClause, ImplementsClause? targetImplementsClause) {
    if (currentImplementsClause == null && targetImplementsClause != null) {
      final currentTypeParams = currentClassDeclaration.typeParameters?.rightBracket.end;
      final currentExtendsClause = currentClassDeclaration.extendsClause?.end;
      final currentWithClause = currentClassDeclaration.withClause?.end;
      final offset = currentWithClause ?? currentExtendsClause ?? currentTypeParams ?? currentClassDeclaration.name.end;
      fixList.add(FixInfo(
        offset: offset,
        length: 0,
        replace: " ${targetImplementsClause.toSource()}",
      ));
    } else if (currentImplementsClause != null && targetImplementsClause != null) {
      final List<String> addInterfaceList = [];
      for (final targetInterface in targetImplementsClause.interfaces) {
        final foundInterface = currentImplementsClause.interfaces.firstWhereOrNull((element) => element.name2.value() == targetInterface.name2.value());
        if (foundInterface == null) {
          addInterfaceList.add(targetInterface.toSource());
        } else if (foundInterface.toSource() != targetInterface.toSource()) {
          fixList.add(FixInfo(
            offset: foundInterface.offset,
            length: foundInterface.length,
            replace: targetInterface.toSource(),
          ));
        }
      }
      if (addInterfaceList.isNotEmpty) {
        fixList.add(FixInfo(
          offset: currentImplementsClause.interfaces.first.offset,
          length: 0,
          replace: "${addInterfaceList.join(", ")}, ",
        ));
      }
    }
  }

  void _compareTypedParameters(ClassDeclaration currentClassDeclaration, TypeParameterList? currentTypeParameters, TypeParameterList? targetTypeParameters) {
    if (currentTypeParameters == null && targetTypeParameters != null) {
      fixList.add(FixInfo(
        offset: currentClassDeclaration.name.end,
        length: 0,
        replace: targetTypeParameters.toSource(),
      ));
    } else if (currentTypeParameters != null && targetTypeParameters != null) {
      if (currentTypeParameters.toSource() != targetTypeParameters.toSource()) {
        fixList.add(FixInfo(
          offset: currentTypeParameters.offset,
          length: currentTypeParameters.length,
          replace: targetTypeParameters.toSource(),
        ));
      }
    } else if (currentTypeParameters != null && targetTypeParameters == null) {
      fixList.add(FixInfo(
        offset: currentTypeParameters.offset,
        length: currentTypeParameters.length,
        replace: "",
      ));
    }
  }

  void _compareMembers(ClassDeclaration classDeclaration, NodeList<ClassMember> currentMembers, NodeList<ClassMember> targetMembers) {
    final lastConstructor = currentMembers.lastWhereOrNull((element) => element is ConstructorDeclaration);
    final firstMethod = currentMembers.firstWhereOrNull((element) => element is MethodDeclaration);
    for (final targetMember in targetMembers) {
      if (targetMember is MethodDeclaration) {
        final currentMember = currentMembers.firstWhereOrNull((element) => element is MethodDeclaration && element.name.lexeme == targetMember.name.lexeme) as MethodDeclaration?;
        if (currentMember == null) {
          if (classDeclaration.abstractKeyword != null) {
            continue;
          }
          compareDirectivesList(target.directives, source.directives);
          final offset = lastConstructor?.end ?? firstMethod?.end ?? classDeclaration.leftBracket.end;
          fixList.add(FixInfo(
            offset: offset,
            length: 0,
            replace: _ident("\n${formatter(targetMember.toSource())}", 2),
          ));
        } else {
          _compareReturns(currentMember, currentMember.returnType, targetMember.returnType);
          _compareParameters(currentMember.parameters, targetMember.parameters);
          _compareMetadata(currentMember, currentMember.metadata, targetMember.metadata);
        }
      }
    }
  }

  void _compareParameters(FormalParameterList? currentParameters, FormalParameterList? targetParameters) {
    if (currentParameters != null && targetParameters != null && targetParameters.parameters.isNotEmpty) {
      final targetSource = targetParameters.toSource();
      final currentSource = currentParameters.toSource().substring(1);
      if (!currentSource.startsWith(targetSource.substring(1, targetSource.length - 1))) {
        fixList.add(FixInfo(
          offset: currentParameters.offset,
          length: currentParameters.length,
          replace: targetParameters.toSource(),
        ));
      }
    }
  }

  void _compareMetadata(MethodDeclaration currentMethod, NodeList<Annotation> currentMetadataList, NodeList<Annotation> targetMetadataList) {
    final addMetadataList = <String>[];
    for (final targetMetadata in targetMetadataList) {
      final currentMetadata = currentMetadataList.firstWhereOrNull((element) => element.name.name == targetMetadata.name.name);
      if (currentMetadata == null) {
        addMetadataList.add(targetMetadata.toSource());
      }
    }
    if (addMetadataList.isNotEmpty) {
      fixList.add(FixInfo(
        offset: currentMethod.offset,
        length: 0,
        replace: _ident("${addMetadataList.join("\n")}\n", 2).trimLeft(),
      ));
    }
  }

  void _compareReturns(MethodDeclaration currentMember, TypeAnnotation? currentReturnType, TypeAnnotation? targetReturnType) {
    if (currentReturnType == null && targetReturnType != null) {
      fixList.add(FixInfo(
        offset: currentMember.name.offset,
        length: 0,
        replace: "${targetReturnType.toSource()} ",
      ));
    } else if (currentReturnType != null && targetReturnType != null) {
      if (currentReturnType.toSource() != targetReturnType.toSource()) {
        fixList.add(FixInfo(
          offset: currentReturnType.offset,
          length: currentReturnType.length,
          replace: targetReturnType.toSource(),
        ));
      }
    }
  }

  String _ident(String code, int spaces) {
    return code.replaceAll(RegExp(r'^', multiLine: true), "".padRight(spaces));
  }
}
