# Safe Bloc

<a href="https://netglade.cz/en">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/netglade/.github/main/assets/netglade_logo_light.png">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/netglade/.github/main/assets/netglade_logo_dark.png">
    <img alt="netglade" src="https://raw.githubusercontent.com/netglade/.github/main/assets/netglade_logo_dark.png">
  </picture>
</a>

Developed with 💚 by [netglade][netglade_link]

[![license: MIT][license_badge]][license_badge_link]
[![style: netglade analysis][style_badge]][style_badge_link]

---

An extension to [bloc state management library](https://github.com/felangel/bloc) that manages unexpected exceptions in a code and displays them as customizable user-friendly error messages.

---

## Overview
A library that helps to automatically handle all the code exceptions that can occur in blocs or cubits and presents them to the user using a dedicated widget `UnexpectErrorHandler`. The `UnexpectErrorHandler` widget can be customized so that all the error dialogs and screens match your app design. In addition, the exceptions processing is also customizable, they can be either displayed, only logged or totally ignored. `safe_bloc` also offers an advantage of optional onError callback, that is called each time an exception occurs.

This library also distinguishes between two types of error: error state and error actions:
1. **Error state**: These occur only during the initial screen loading. If the screen loading fails, there's no data to display to the user, and the `UnexpectErrorHandler` presents an error screen represented by `errorScreen` parameter.

2. **Error Actionse**: These typically happen when a user triggers an action (e.g., pressing a button) on an already loaded screen. In this scenario, we don't want to disrupt the user's experience by displaying an error screen and erasing any loaded data. Instead, the `safe_bloc` library simply shows an error dialog, informing the user that the action is currently unavailable. This ensures that the screen's existing data remains accessible to the user.

## Usage

First, create an error state that will be emitted in case exception occurs. This state must implement `UnexpectedErrorAPI`.
```dart
sealed class MyBlocState {}

final class BlocErrorState extends MyBlocState  implements UnexpectedErrorAPI {
  @override
  final UnexpectedError error;

  BlocErrorState(this.error);
}
```

# Bloc
In case you are using `Bloc`, use `SafeBloc` class instead of standard `Bloc`:
```dart
class MyBloc extends SafeBloc<MyBlocEvent, MyBlocState> {
  // body
}
```
Now, whenever you are registering a new event handler, use `onSafe<EVENT>`
 event handler instead of standard `on<EVENT>`:
 ```dart
onSafe<MyBlocEvent>((event, emit, {required trackingId}) async {
   // do something
});
 ```
[netglade_link]: https://netglade.com/en
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_badge_link]: https://opensource.org/licenses/MIT
[style_badge]: https://img.shields.io/badge/style-netglade_analysis-26D07C.svg
[style_badge_link]: https://pub.dev/packages/netglade_analysis
