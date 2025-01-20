import 'dart:async';
import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/src/base_effect.dart';
import 'package:safe_bloc/src/safe_bloc_base.dart';
import 'package:safe_bloc/src/unexpected_error.dart';

typedef UnexpectedErrorWidgetBuilder = Widget Function(
  BuildContext context,
  UnexpectedError error,
);

typedef UnexpectedErrorActionCallback = Future<void> Function(
  BuildContext context,
  UnexpectedError error,
);

/// Widget that listens to the events and states that implement [UnexpectedErrorBase] in specified the [BLOC].
/// Subsequently, it calls [onErrorAction] in case of error event
/// or displays a [errorScreen] in case of error state.
class UnexpectedErrorHandler<BLOC extends SafeBlocBase<STATE, BaseEffect>, STATE> extends StatelessWidget {
  final Widget child;

  /// Callback that returns a [Widget] that is displayed if state that implements [UnexpectedErrorBase] is emitted by [BLOC].
  // ignore: prefer-correct-callback-field-name, does not need to start with on, returns error screen Widget
  final UnexpectedErrorWidgetBuilder? errorScreen;

  /// Callback that is invoked if event that implements [UnexpectedErrorBase] is emitted by [BLOC].
  final UnexpectedErrorActionCallback? onErrorAction;

  const UnexpectedErrorHandler({
    required this.child,
    this.errorScreen,
    this.onErrorAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<BLOC?>();

    if (bloc == null) return child;

    return BlocPresentationListener<BLOC, BaseEffect>(
      listener: _handleError,
      child: BlocBuilder<BLOC, STATE>(
        builder: (context, state) {
          if (state is UnexpectedErrorBase && !state.error.isAction) {
            return Material(
              child: Builder(
                builder: (context) {
                  final screen = errorScreen;
                  if (screen == null) {
                    return Center(child: Text(state.error.toString()));
                  }

                  return screen(context, state.error);
                },
              ),
            );
          }

          return child;
        },
      ),
    );
  }

  void _handleError(BuildContext context, BaseEffect effect) {
    // BaseEffect can implement UnexpectedErrorBase
    // ignore: avoid-unrelated-type-assertions
    if (effect case final UnexpectedErrorBase error) {
      if (onErrorAction != null) {
        unawaited(onErrorAction?.call(context, error.error));
      } else {
        unawaited(_showAlertDialog(context, error: error.error));
      }
    }
  }

  Future<void> _showAlertDialog(
    BuildContext context, {
    required UnexpectedError error,
  }) async {
    await showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Something went wrong!'),
        content: Text(error.error.toString()),
        actions: [
          if (Platform.isAndroid)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          if (Platform.isIOS)
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }
}
