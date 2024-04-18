part of 'sviper.dart';

abstract class SviperConfiguration {
  final SviperState? _state;
  final Object? _input;
  final SviperInteractor? _interactor;
  final SviperRouter? _router;

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
