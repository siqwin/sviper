part of 'sviper.dart';

/// Defines the configuration of a Sviper module
abstract class SviperConfiguration {
  final SviperState? _state;
  final Object? _input;
  final SviperInteractor? _interactor;
  final SviperRouter? _router;

  /// Default constructor
  SviperConfiguration({
    SviperState? state,
    Object? input,
    SviperInteractor? interactor,
    SviperRouter? router,
  })  : _state = state,
        _input = input,
        _interactor = interactor,
        _router = router;
}
