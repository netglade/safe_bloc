import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/safe_bloc.dart';

export 'package:bloc/bloc.dart' show Emitter;

abstract class SafeCubit<STATE> extends Cubit<STATE>
    with SafeBlocBaseMixin<STATE>, BlocPresentationMixin<STATE, BaseEffect>
    implements SafeBlocBase<STATE> {
  SafeCubit(super.initialState);

  @protected
  FutureOr<void> safeCall(
    FutureOr<void> Function(String trackingId) callback, {
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    // ignore: avoid-dynamic, has to be dynamic
    FutureOr<void> Function(dynamic error, StackTrace stackTrace)? onIgnoreError,
  }) =>
      safeCallInternal(
        safeEmit,
        callback,
        devErrorMessage: devErrorMessage,
        isAction: isAction,
        ignoreError: ignoreError,
        onIgnoreError: onIgnoreError,
        invokeActionSideEffect: emitPresentation,
        onError: onUnexpectedError,
      );

  @override
  FutureOr<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) => Future.value();
}
