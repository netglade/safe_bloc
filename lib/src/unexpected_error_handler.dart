import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/safe_bloc.dart';

typedef UnexpectedErrorWidgetBuilder = Widget Function(BuildContext context, UnexpectedError error);

class UnexpectedErrorHandler<BLOC extends SafeBlocBase<STATE>, STATE> extends StatelessWidget {
  final Widget child;
  final UnexpectedErrorWidgetBuilder errorWidget;
  final Future<void> Function(UnexpectedError error) onError;

  const UnexpectedErrorHandler({
    required this.child,
    required this.errorWidget,
    required this.onError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<BLOC?>();

    if (cubit == null) return child;

    return BlocPresentationListener<BLOC>(
      listener: (context, effect) async {
        if (effect is UnexpectedErrorAPI) {
          final navigator = Navigator.of(context);

          final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
          if (!isCurrent && navigator.canPop()) navigator.pop();

          await onError.call(effect.error);
        }
      },
      child: BlocBuilder<BLOC, STATE>(
        builder: (context, state) {
          if (state is UnexpectedErrorAPI && !state.error.isAction) {
            return Material(
              child: Builder(
                builder: (context) {
                  return errorWidget(context, state.error);
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
