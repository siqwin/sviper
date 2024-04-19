class Sviper {
  /// Specifies whether the module has an Input
  final bool? hasInput;

  /// Specifies whether the module has an Output
  final bool? hasOutput;

  /// Specifies whether the module has a State
  final bool? hasState;

  /// Specifies whether the module has a View
  final bool? hasView;

  /// Specifies whether the module has an Interactor
  final bool? hasInteractor;

  /// Specifies whether the module has a Router
  final bool? hasRouter;

  /// Specifies whether the module is a screen or a widget
  final bool isWidget;

  /// Allows the module to extend another module
  final Type? extend;

  /// Annotation for creating a screen module
  const Sviper({
    this.hasInput,
    this.hasOutput,
    this.hasState,
    this.hasView,
    this.hasInteractor,
    this.hasRouter,
    this.extend,
  }) : isWidget = false;

  /// Annotation for creating a widget module
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
