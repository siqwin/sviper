part of 'sviper.dart';

abstract class SviperView extends State<SviperWidget> {
  SviperPresenter? _presenter;

  Object? get presenter => _presenter;

  Object? get state => _presenter?._state;

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
