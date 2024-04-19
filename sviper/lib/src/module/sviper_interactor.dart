part of 'sviper.dart';

/// Base class for Interactor's
class SviperInteractor {
  /// Default constructor
  const SviperInteractor();

  /// This method will be invoked when module is disposing
  /// When this method overrides, it must call super.dispose()
  @mustCallSuper
  void dispose() {}
}
