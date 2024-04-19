part of 'sviper.dart';

/// An interface for app-specific router that manage navigation
abstract class ISviperRouter<T> {}

/// Base class for module router
abstract class SviperRouter {
  /// Getter for the app-specific router that manage navigation
  ISviperRouter<void>? get router;

  /// Default constructor
  const SviperRouter();

  /// This method will be invoked when module is disposing
  /// When this method overrides, it must call super.dispose()
  @mustCallSuper
  void dispose() {}
}
