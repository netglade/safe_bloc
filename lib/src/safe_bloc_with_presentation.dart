// ignore_for_file: avoid-bloc-public-methods, prefer-match-file-name, avoid-declaring-call-method

import 'dart:async';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/src/safe_bloc_base.dart';

export 'package:bloc/bloc.dart' show Emitter;

/// An [SafeEmitter] is a class which is capable of emitting new states.
/// Also checks if stateController is not closed before each emit.
class SafeEmitter<State> {
  final BlocBase<State> bloc;
  final Emitter<State> emitter;

  const SafeEmitter({required this.bloc, required this.emitter});

  void call(State state) {
    if (bloc.isClosed) return;

    emitter(state);
  }
}

/// An event handler is responsible for reacting to an incoming [Event]
/// and can emit zero or more states via the [SafeEmitter].
/// Contains a unique `trackingId` that can be passed to emitter for tracking the event.
typedef SafeEventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  SafeEmitter<State> emit, {
  required String trackingId,
});

/// A class that extends [Bloc] and encapsulates the [Emitter] with a [SafeEmitter] that catches all exceptions
/// using a try-catch block and processes them based on specified parameters.
abstract class SafeBlocWithPresentation<EVENT, STATE, EFFECT> extends Bloc<EVENT, STATE>
    with SafeBlocBaseMixin<STATE, EFFECT>, BlocPresentationMixin<STATE, EFFECT>
    implements SafeBlocBase<STATE, EFFECT> {
  SafeBlocWithPresentation(super.initialState);

  /// Register a [SafeEventHandler] for an event of type [E].
  /// There should only ever be one event handler per event type [E].
  ///  - [devErrorMessage] - A string message that is passes to UnexpectedError object in emitted effect or state.
  ///  - [isAction] - If set to true, the passed event [E] is a user action (e.g button pressing). If set to false(default), the passed event [E] is a initial data loading.
  ///  - [ignoreError]  - Bool that indicates whether the exception should be ignored. If set to `true`, the exception is caught, but no error state is emitted.
  ///  - [onIgnoreError] - A callback that is invoked if the exception in the [SafeEventHandler] occurs and `ignoreError` parameter is set to `true`.
  ///  - [transformer] - Same as [Bloc.on] transformer.
  void onSafe<E extends EVENT>(
    SafeEventHandler<E, STATE> handler, {
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    OnIgnoreError? onIgnoreError,
    EventTransformer<E>? transformer,
    ErrorMapper<STATE>? errorMapper,
  }) {
    on<E>(
      (event, emit) => safeCallInternal(
        emit.call,
        (trackingId) async {
          await handler(
            event,
            SafeEmitter(bloc: this, emitter: emit),
            trackingId: trackingId,
          );
        },
        devErrorMessage: devErrorMessage,
        isAction: isAction,
        ignoreError: ignoreError,
        onIgnoreError: onIgnoreError,
        invokeActionSideEffect: emitPresentation,
        onError: onUnexpectedError,
        errorMapper: errorMapper,
      ),
      transformer: transformer,
    );
  }

  @override
  Future<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) => Future.value();
}
