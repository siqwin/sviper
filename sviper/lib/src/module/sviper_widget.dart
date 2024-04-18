part of 'sviper.dart';

abstract class SviperWidget extends StatefulWidget {
  Object getInput();

  const SviperWidget({
    super.key,
  });

  @override
  @protected
  State<StatefulWidget> createState() => buildView(); // ignore: no_logic_in_create_state

  @protected
  @factory
  State<StatefulWidget> buildView();

  SviperPresenter buildConfiguration(SviperView view);
}

abstract class SviperPage<Output> extends SviperWidget {
  final String name;
  final Object _input;

  @override
  Object getInput() => _input;

  const SviperPage(
    this._input, {
    super.key,
    required this.name,
  });
}
