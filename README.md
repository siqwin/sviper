Sviper is an architectural pattern inspired by VIPER, tailored specifically for Flutter projects. 
It's particularly beneficial for large-scale projects, providing a structured approach to organizing code. 

## Motivation

Flutter is awesome, but managing large codebases, where a single screen file spans thousands of lines encompassing navigation, logic, dependency management, state management, etc., can be challenging.

The Sviper addresses this issue by dividing the code into distinct parts. While this approach increases the number of files and may seem like overengineering for simple cases, it significantly simplifies code maintenance for more complex scenarios.

This separation of code allows developers to concentrate on specific parts of a component during development, or quickly navigate to the necessary part for modifications. With Sviper, you can be confident that all navigation is handled in the Router file, all data is managed in the Interactor file, the layout is defined in the View file, and the logic is in the Presenter. This is arguably more convenient than sifting through a large view code file to determine where events are handled and transitions occur.

It's important to note that this plugin is not intended to replace other packages. Instead, it aids in organizing the component parts. You can still use any packages for dependency management, state management, routers, etc., in conjunction with Sviper.

## Install
In the pubspec.yaml of your flutter project, add the following dependency:
```
dependencies:
  sviper: ^1.0.0

dev_dependency:
  build_runner: any
  sviper_generator: ^1.0.0
```
**OR** run the following commands in your project folder

```
flutter pub add sviper
flutter pub add dev:build_runner
flutter pub add dev:sviper_generator
```
## Usage

Simple define a class with the `@Sviper` annotation as shown below:

```
import 'package:sviper/sviper.dart';

@Sviper()
class HomeScreen {}
```

Then, execute the code generator:

```
dart run build_runner build
```

This will automatically generate all the necessary code for the screen.

### Notes

- Considering that each Sviper screen or widget consists of numerous files, it's beneficial to organize them in separate folders for better manageability.
- The filenames of the generated files will be based on the filename where the annotated class is defined. Therefore, it's advisable to use meaningful filenames.
- Use the `@Sviper` annotation for Pages (Screens), and `@Sviper.widget` annotation for Widgets (Components).

### Parameters

The `@Sviper` annotation accepts several parameters. 
- You can exclude any part of the module using the `hasInput`, `hasOutput`, `hasState`, `hasView`, `hasInteractor`, `hasRouter` parameters.
- You can extend a module from another one using the 'extend' parameter.

## Sviper module architecture

![Sviper Module](/docs/module.svg)

Sviper consists of five main parts: View, State, Presenter, Interactor and Router.

- **View**: The View is responsible for displaying the user interface and managing user interactions. It communicates user actions to the Presenter and displays information based on the State.

- **Interactor**: The Interactor handles data exchange with external services related to the module. It retrieves data from databases, initiates network calls, and more. The Interactor then passes this data to the Presenter.

- **Presenter**: The Presenter receives data from the Interactor, formats it for the View, and updates the State. It also processes user actions received from the View.

- **State**: The State represents the current state of a module. It doesn't contain any logic.

- **Router**: The Router manages screen navigation. It executes instructions received from the Presenter.

Also, module includes a few more entities:

- **Input**: Data supplied to a module's input.

- **Output**: Data output from a module.

- **SviperModule**: SviperPage / SviperWidget - builders that assemble the module.

## TODO

- [ ] Add example app
- [ ] Tool for renaming modules
- [ ] Example of module testing
