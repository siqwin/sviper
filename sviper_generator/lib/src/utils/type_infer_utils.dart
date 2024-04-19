import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:sviper_generator/src/extensions/dart_type_extension.dart';

class TypeInferUtils {
  TypeInferUtils._();

  static List<TypeReference> getTypeParameterElement(List<TypeParameterElement> elements, List<Reference>? parentGenericParams) {
    if (parentGenericParams != null && parentGenericParams.length != elements.length) {
      throw Exception();
    }
    final result = <TypeReference>[];
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      final elementBound = element.bound;
      TypeReference? bound;
      if (elementBound != null) {
        bound = getTypeParameterBound(element, elementBound);
      }
      result.add(TypeReference(
        (t) => t
          ..symbol = parentGenericParams == null ? element.name : parentGenericParams[i].symbol
          ..url = parentGenericParams == null ? null : parentGenericParams[i].url
          ..bound = bound,
      ));
    }
    return result;
  }

  static TypeReference getTypeParameterBound(TypeParameterElement parent, DartType elementBound) {
    if (elementBound is InterfaceType) {
      final typeArguments = elementBound.typeArguments;
      return TypeReference(
        (t) => t
          ..symbol = elementBound.element.name
          ..url = getPackageUrlForType(parent, elementBound)
          ..types.addAll(typeArguments.map((it) => getTypeParameterBound(parent, it))),
      );
    } else {
      return TypeReference((t) => t..symbol = elementBound.getDisplayString(withNullability: true));
    }
  }

  static String? getPackageUrlForType(Element parent, DartType elementBound) {
    if (elementBound.isDartType) {
      return null;
    }
    final curUri = Uri.tryParse(elementBound.element?.location?.components.firstOrNull ?? elementBound.element?.source?.uri.toString() ?? "");
    if (curUri == null || curUri.scheme != "package") {
      return null;
    }
    final typePackage = AssetId.resolve(curUri).package;
    final parentPackage = AssetId.resolve(parent.librarySource!.uri).package;
    if (typePackage != parentPackage) {
      final parentLibrary = parent.library;
      if (parentLibrary != null) {
        for (final importLibrary in parentLibrary.libraryImports) {
          final importedLibrary = importLibrary.importedLibrary;
          if (importedLibrary != null) {
            final definedNames = importedLibrary.library.exportNamespace.definedNames;
            final targetType = definedNames[elementBound.getDisplayString(withNullability: false)];
            if (targetType != null) {
              return AssetId.resolve(Uri.parse(importedLibrary.source.uri.toString())).uri.toString();
            }
          }
        }
      }
    }
    return  elementBound.element?.library?.source.uri.toString() ?? elementBound.element?.source?.uri.toString() ?? AssetId.resolve(curUri).uri.toString();
  }
}
