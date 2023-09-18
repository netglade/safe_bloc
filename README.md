<a href="https://github.com/netglade">
  <picture >
    <source media="(prefers-color-scheme: dark)" height='120px' srcset="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-dark.png">
    <source media="(prefers-color-scheme: light)" height='120px' srcset="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-light.png">
    <img alt="netglade" height='120px' src="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-light.png">
  </picture>
</a>

Developed with 💚 by [netglade][netglade_link]

[![ci][ci_badge]][ci_badge_link]
[![pub package][safe_bloc_pub_badge]][safe_bloc_pub_badge_link]
[![license: MIT][license_badge]][license_badge_link]
[![style: netglade analysis][style_badge]][style_badge_link]
[![Discord][discord_badge]][discord_badge_link]


---

An extension to [bloc state management library](https://github.com/felangel/bloc) that manages unexpected exceptions in a code and displays them as customizable user-friendly error messages.

## Overview
A library that provides a unified solution to code exception handling in blocs and cubits. In addition, it presents the errors to the user using a dedicated widget `UnexpectErrorHandler`. This widget can be customized so that all the error dialogs and screens match your app design. Moreover, the exception processing is customizable, they can be either displayed, logged, or ignored. `safe_bloc` also offers the advantage of an optional `onUnexpectedError` callback, that is called each time an exception occurs. This can be suitable especially for exception logging.

This library also distinguishes between two types of error: error state and error actions:
* **Error states**: These occur only during the initial screen loading. If the screen loading fails, there's no data to display to the user, and the `UnexpectErrorHandler` presents an error screen represented by the `errorScreen` parameter.

* **Error actions**: These typically happen when a user triggers an action (e.g., pressing a button) on an already loaded screen. In this scenario, we don't want to disrupt the user's experience by displaying an error screen and erasing the loaded data. Instead, the `safe_bloc` library simply shows an error dialog, informing the user that the action is currently unavailable. This ensures that the screen's existing data remains accessible to the user.

## Usage

### 1. Create UnexpectedError state
First, create an error state that will be emitted in case an exception occurs. This state must implement `UnexpectedErrorBase`.
```dart
sealed class MyAppState {}

final class MyAppErrorState extends MyAppState implements UnexpectedErrorBase {
  @override
  final UnexpectedError error;

  MyAppErrorState(this.error);
}
```

### 2. Use SafeBloc or SafeCubit class

#### Bloc
In case you are using `Bloc`, extend your bloc with a `SafeBloc` class and override its `errorState` getter with the error state created in the previous step:
```dart
class MyAppBloc extends SafeBloc<MyAppEvent, MyAppState> {
  // body

  @override
  MyAppState Function(UnexpectedError error) get errorState => MyAppErrorState.new;
}
```
Now, whenever you register a new event handler, use `onSafe<EVENT>`
event handler instead of standard `on<EVENT>`:
```dart
  onSafe<MyBlocEvent>(event, emit, {required trackingId}) async {
     // do something
  }
```

#### Cubit
Similarly, if you are using `Cubit`, extend your cubit with as `SafeCubit` class and override the `errorState` getter with the error state you have created in the first step. Then, wrap all the public cubit methods in a `safeCall` method as follows:
```dart
class MyAppCubit extends SafeCubit<MyAppState> {
  MyAppCubit(super.initialState);

  FutureOr<void> someMethod() => safeCall((trackingId) {
    // do something
  });

  @override
  MyAppState Function(UnexpectedError error) get errorState => MyAppErrorState.new;
}
```

Each time an exception occurs, it is caught by the parent class and `MyAppErrorState` is emitted. This state contains an `UnexpectedError` object with additional information about the exception including the exception itself.

Both `onSafe` and `safeCall` provide a unique `trackingId` that can be used to track the user actions. Both methods also provide additional parameters:
* `devErrorMessage`(optional) - string message that is passed to the `UnexpectedError` object, can be handy for logging
* `isAction`- bool that indicates if the method is an error action or error state. When set to `true`, `UnexpectedErrorHandler` shows an error dialog or calls `onErrorAction` callback if specified. When set to `false` (default), `UnexpectedErrorHandler` shows an error screen specified by `errorScreen` parameter.
* `ignoreError` - bool that indicates whether the exception should be ignored. If set to `true`, the exception is caught, but MyAppErrorState is not emitted.
* `onIgnoreError`(optional) - a callback that is invoked if the exception occurs and `ignoreError` parameter is set to `true`

Additionally, `SafeBloc` and `SafeCubit` offer the option to override the `onUnexpectedError` method. This method is invoked whenever an exception is thrown so that it can be useful for exception logging.

### 3. Present the error in the UI
Use the `UnexpectErrorHandler` in your widget tree in order to display the errors:
```dart
UnexpectedErrorHandler<MyAppBloc, MyAppState>(
  errorScreen: (context, error) => Text(error.toString()),
  onErrorAction: (context, error) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(error.toString()));
      },
    );
  },
  child: MyWidget(),
)
 ```

`UnexpectErrorHandler` provides a parameter `errorScreen` to display the errors during the initial screen loading and parameter `onErrorAction` for the error actions. `onErrorAction` callback is invoked if the `isAction` parameter of the `onSafe`/`safeCall` method is set to `true`.

### Using presentation events in you app
This library makes use of the [bloc_presentation](https://pub.dev/packages/bloc_presentation) library to handle the user error action events. This library adds another stream to the bloc/cubit in order to present one-time events (e.g. dialogs or snackbars) to the user. `safe_bloc` library uses a `BaseEffect` as a presentation event
and its inherited `UnexpectedErrorEffect` class for exception handling. However, if you have specific presentation events you would like to use in your bloc or cubit, you can create your own implementation of presentation events and use them in combination with `SafeBlocWithPresentation` or `SafeCubitWithPresentation` like this:
```dart
class MyAppCubit extends SafeCubitWithPresentation<MyAppState, MyAppPresentationEvent> {
  MyAppCubit(super.initialState);

  FutureOr<void> someMethod() => safeCall((trackingId) {
    // do something
  });

  @override
  MyAppState Function(UnexpectedError error) get errorState => MyAppErrorState.new;

  @override
  MyAppPresentationEvent Function(UnexpectedError error) get errorEffect => MyAppErrorPresentationEvent.new;
}
```
 
[netglade_link]: https://netglade.com/en

[ci_badge]: https://github.com/netglade/safe_bloc/workflows/ci/badge.svg
[ci_badge_link]: https://github.com/netglade/safe_bloc/actions
[safe_bloc_pub_badge]: https://img.shields.io/pub/v/safe_bloc.svg
[safe_bloc_pub_badge_link]: https://pub.dartlang.org/packages/safe_bloc
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_badge_link]: https://opensource.org/licenses/MIT
[style_badge]: https://img.shields.io/badge/style-netglade_analysis-26D07C.svg
[style_badge_link]: https://pub.dev/packages/netglade_analysis
[discord_badge]: https://img.shields.io/discord/1091460081054400532.svg?logo=discord&color=blue
[discord_badge_link]: https://discord.gg/WfrS8MAd
