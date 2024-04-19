part of 'sviper.dart';

/// Base class for State's
class SviperState {
  /// Default constructor
  const SviperState();

  /// This method will be invoked when module is disposing
  /// When this method overrides, it must call super.dispose()
  @mustCallSuper
  void dispose() {}
}
