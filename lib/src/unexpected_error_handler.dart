import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/safe_bloc.dart';

typedef UnexpectedErrorWidgetBuilder = Widget Function(BuildContext context, UnexpectedError error);

typedef UnexpectedErrorActionCallback = Future<void> Function(UnexpectedError error);

class UnexpectedErrorHandler<BLOC extends SafeBlocBase<STATE>, STATE> extends StatelessWidget {
  final Widget child;
  // TODO(dev): implement default error screen
  final UnexpectedErrorWidgetBuilder errorScreen;
  final UnexpectedErrorActionCallback? onErrorAction;

  const UnexpectedErrorHandler({
    required this.child,
    required this.errorScreen,
    this.onErrorAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<BLOC?>();

    if (bloc == null) return child;

    return BlocPresentationListener<BLOC, BaseEffect>(
      listener: (context, effect) async {
        if (effect is UnexpectedErrorAPI) {
          final error = (effect as UnexpectedErrorAPI).error;

          if (onErrorAction != null) {
            await onErrorAction?.call(error);
          } else {
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
      },
      child: BlocBuilder<BLOC, STATE>(
        builder: (context, state) {
          if (state is UnexpectedErrorAPI && !state.error.isAction) {
            return Material(
              child: Builder(
                builder: (context) {
                  return errorScreen(context, state.error);
                },
              ),
            );
          }
          return child;
        },
      ),
    );
  }
}
