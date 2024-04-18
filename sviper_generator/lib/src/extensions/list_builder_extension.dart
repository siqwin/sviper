import 'package:built_collection/built_collection.dart';

extension ListBuilderExtension<T> on ListBuilder<T> {
  void addNotNull(T? value) {
    if (value != null) {
      add(value);
    }
  }

  void addAllNotNull(Iterable<T>? value) {
    if (value != null) {
      addAll(value);
    }
  }
}
