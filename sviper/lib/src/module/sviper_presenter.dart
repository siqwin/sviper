part of 'sviper.dart';

/// Base class for Presenter's
abstract class SviperPresenter {
  final SviperState? _state;
  final SviperInteractor? _interactor;
  final SviperRouter? _router;

  // ignore: prefer_final_fields
  Object? _input;
  bool _disposed = false;

  /// Default constructor
  SviperPresenter(SviperConfiguration configuration)
      : _state = configuration._state,
        _input = configuration._input,
        _interactor = configuration._interactor,
        _router = configuration._router;

  /// Getter for the input of the module
  Object? get input => _input;

  /// Getter for the state of the module
  Object? get state => _state;

  /// Getter for the interactor of the module
  Object? get interactor => _interactor;

  /// Getter for the router of the module
  Object? get router => _router;

  /// Getter for the disposed flag
  bool get disposed => _disposed;

  /// This method will be invoked when module input is changed
  void didUpdateInput(Object oldInput) {}

  /// This method will be invoked when module is disposing
  /// When this method overrides, it must call super.dispose()
  @mustCallSuper
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _interactor?.dispose();
    _state?.dispose();
    _router?.dispose();
  }
}
