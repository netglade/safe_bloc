// ignore_for_file: avoid-bloc-public-methods, prefer-match-file-name, avoid-declaring-call-method

import 'dart:async';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/src/safe_bloc_base.dart';

export 'package:bloc/bloc.dart' show Emitter;

class SafeEmitter<State> {
  final BlocBase<State> bloc;
  final Emitter<State> emitter;

  const SafeEmitter({required this.bloc, required this.emitter});

  void call(State state) {
    if (bloc.isClosed) return;

    emitter(state);
  }
}

typedef SafeEventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  SafeEmitter<State> emit, {
  required String trackingId,
});

abstract class SafeBloc<EVENT, STATE> extends Bloc<EVENT, STATE>
    with SafeBlocBaseMixin<STATE>, BlocPresentationMixin<STATE>
    implements SafeBlocBase<STATE> {
  SafeBloc(super.initialState);

  void onSafe<E extends EVENT>(
    SafeEventHandler<E, STATE> handler, {
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    FutureOr<void> Function(Object? error, StackTrace stackTrace)? onIgnoreError,
  }) {
    on<E>(
      (event, emit) async => safeCallInternal(
        emit.call,
        (trackingId) => handler(
          event,
          SafeEmitter(bloc: this, emitter: emit),
          trackingId: trackingId,
        ),
        devErrorMessage: devErrorMessage,
        isAction: isAction,
        ignoreError: ignoreError,
        onIgnoreError: onIgnoreError,
        invokeActionSideEffect: emitPresentation,
        onError: onUnexpectedError,
      ),
    );
  }
}
