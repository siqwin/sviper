part of 'sviper.dart';

abstract class SviperPresenter {
  final SviperState? _state;
  final SviperInteractor? _interactor;
  final SviperRouter? _router;

  Object? _input;
  bool _disposed = false;

  SviperPresenter(SviperConfiguration configuration)
      : _state = configuration._state,
        _input = configuration._input,
        _interactor = configuration._interactor,
        _router = configuration._router;

  Object? get input => _input;

  Object? get state => _state;

  Object? get interactor => _interactor;

  Object? get router => _router;

  bool get disposed => _disposed;

  void didUpdateInput(Object oldInput) {}

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
