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
A library that helps to automatically handle all the code exceptions that can occur in blocs or cubits and presents them to the user using a dedicated widget `UnexpectErrorHandler`. The `UnexpectErrorHandler` widget can be customized so that all the error dialogs and screens match your app design. In addition, the exceptions processing is also customizable, they can be either displayed, only logged or totally ignored. `safe_bloc` also offe an advantage of optional onError callback, that is called each time an exception occurs.

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
In case you are using `Bloc`, use `SafeBloc` class instead of statndard `Bloc`:
```dart
class MyBloc extends SafeBloc<MyBlocEvent, MyBlocState> {
  // body
}
```

[netglade_link]: https://netglade.com/en
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_badge_link]: https://opensource.org/licenses/MIT
[style_badge]: https://img.shields.io/badge/style-netglade_analysis-26D07C.svg
[style_badge_link]: https://pub.dev/packages/netglade_analysis
