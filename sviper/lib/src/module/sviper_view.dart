part of 'sviper.dart';

/// Base class for View's
abstract class SviperView extends State<SviperWidget> {
  SviperPresenter? _presenter;

  /// Getter for the presenter of the module.
  Object? get presenter => _presenter;

  /// Getter for the state of the module.
  Object? get state => _presenter?._state;

  /// This method is called only once when the view is initialized.
  /// Use this method instead of `initState` when you need presenter or state.
  void init() {}

  @override
  @mustCallSuper
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_presenter == null) {
      _presenter = widget.buildConfiguration(this);
      init();
    }
  }

  @override
  @mustCallSuper
  void didUpdateWidget(SviperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final presenter = _presenter;
    if (presenter != null) {
      presenter._input = widget.getInput();
      presenter.didUpdateInput(oldWidget.getInput());
    }
  }
}
