part of 'sviper.dart';

abstract class ISviperRouter<T> {}

abstract class SviperRouter {
  Object? get router;

  const SviperRouter();

  @mustCallSuper
  void dispose() {}
}
