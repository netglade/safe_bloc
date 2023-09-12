<a href="https://github.com/netglade">
  <picture >
    <source media="(prefers-color-scheme: dark)" height='120px' srcset="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-dark.png">
    <source media="(prefers-color-scheme: light)" height='120px' srcset="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-light.png">
    <img alt="netglade" height='120px' src="https://raw.githubusercontent.com/netglade/safe_bloc/main/doc/badge-light.png">
  </picture>
</a>

Developed with 💚 by [netglade][netglade_link]

[![license: MIT][license_badge]][license_badge_link]
[![style: netglade analysis][style_badge]][style_badge_link]

---

An extension to [bloc state management library](https://github.com/felangel/bloc) that manages unexpected exceptions in a code and displays them as customizable user-friendly error messages.

## Overview
A library that provides a unified solution to code exceptions handling in blocs and cubits. In addition, it presents the errors to the user using a dedicated widget `UnexpectErrorHandler`. The `UnexpectErrorHandler` widget can be customized so that all the error dialogs and screens match your app design. In addition, the exceptions processing is also customizable, they can be either displayed, only logged or totally ignored. `safe_bloc` also offers an advantage of optional onError callback, that is called each time an exception occurs.

This library also distinguishes between two types of error: error state and error actions:
* **Error states**: These occur only during the initial screen loading. If the screen loading fails, there's no data to display to the user, and the `UnexpectErrorHandler` presents an error screen represented by `errorScreen` parameter.

* **Error Actions**: These typically happen when a user triggers an action (e.g., pressing a button) on an already loaded screen. In this scenario, we don't want to disrupt the user's experience by displaying an error screen and erasing any loaded data. Instead, the `safe_bloc` library simply shows an error dialog, informing the user that the action is currently unavailable. This ensures that the screen's existing data remains accessible to the user.

## Usage


### 1. Create UnexpectedError State
First, create an error state that will be emitted in case exception occurs. This state must implement `UnexpectedErrorAPI`.
```dart
sealed class MyAppState {}

final class MyAppErrorState extends MyAppState implements UnexpectedErrorAPI {
  @override
  final UnexpectedError error;

  MyAppErrorState(this.error);
}
```


### 2. Use SafeBloc or SafeCubit Class

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
onSafe<MyBlocEvent>((event, emit, {required trackingId}) async {
   // do something
});
 ```

#### Cubit
Simirarly, if you are using `Cubit`, extend you cubit with as SafeCubit class and override the `errorState` getter with the error state you have created in the first step. Then, whenever you want to call a cubit method, wrap the method in a `safeCall` method as follows:
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



Each time an exception eccurs, it is catched by the parent class and MyAppErrorState is emited. This state constains a `UnexpectedError` object with additional information about the exception including the exception iteself.

Both `onSafe` and `safeCall` provide a unique `trackingId` that can be used to track the user actions. Both methods also provide addional parameters:
* `devErrorMessage`(optional) - string message that is passed to the `UnexpectedError` object, can be handy for logging
* `isAction`- bool that indicates if the method is error action or error state. When set to `true`, `UnexpectedErrorHandler` shows an error dialog or calls `onErrorAction` callback if specified. When set to `false` (default), `UnexpectedErrorHandler` shows an error screen speciefied by `errorScreen` parameter.
* `ignoreError` - bool that indicates wheather the exception should be ignored. If set to `true`, the exception is catched, but MyAppErrorState is not emitted.
* `onIgnoreError`(optional) - callback that is invoked if the exception occurs and `ignoreError` parameter is se to `true`


### 3. Present the error in UI
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

`UnexpectErrorHandler` provides parameter `errorScreen` to display the errors during the initial screen loading and parameter `onErrorAction` for the error actions. `onErrorAction` callback is invoked if the `isAction` parameter of the `onSafe`/`safeCall` method is set to `true`.
 
[netglade_link]: https://netglade.com/en
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_badge_link]: https://opensource.org/licenses/MIT
[style_badge]: https://img.shields.io/badge/style-netglade_analysis-26D07C.svg
[style_badge_link]: https://pub.dev/packages/netglade_analysis
