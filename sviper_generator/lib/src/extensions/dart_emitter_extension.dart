import 'package:code_builder/code_builder.dart';

extension DartEmitterExtension on DartEmitter {
  String emitLibrary(Library library) {
    return visitLibrary(library).toString();
  }

  String emitMethod(Method method) {
    return visitMethod(method).toString();
  }

  String emitClass(Class clazz) {
    return visitClass(clazz).toString();
  }

  String emitConstructor(Constructor constructor, String className) {
    return visitConstructor(constructor, className).toString();
  }

  String emitType(TypeReference spec) {
    return visitType(spec).toString();
  }
}
