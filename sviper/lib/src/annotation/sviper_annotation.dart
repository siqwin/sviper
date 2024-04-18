class Sviper {
  final bool? hasInput;
  final bool? hasOutput;

  final bool? hasState;
  final bool? hasView;
  final bool? hasInteractor;
  final bool? hasRouter;

  final bool isWidget;
  final Type? extend;

  const Sviper({
    this.hasInput,
    this.hasOutput,
    this.hasState,
    this.hasView,
    this.hasInteractor,
    this.hasRouter,
    this.extend,
  }) : isWidget = false;

  const Sviper.widget({
    this.hasInput,
    this.hasState,
    this.hasView,
    this.hasInteractor,
    this.hasRouter,
    this.extend,
  })  : isWidget = true,
        hasOutput = false;
}
