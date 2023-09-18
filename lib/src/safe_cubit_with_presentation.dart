import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/src/extensions.dart';
import 'package:safe_bloc/src/safe_bloc_base.dart';

export 'package:bloc/bloc.dart' show Emitter;

/// A class that extends [Cubit] for a [safeCall] method that catches all exceptions
/// using a try-catch block and processes them based on specified parameters.
abstract class SafeCubitWithPresentation<STATE, EFFECT> extends Cubit<STATE>
    with SafeBlocBaseMixin<STATE, EFFECT>, BlocPresentationMixin<STATE, EFFECT>
    implements SafeBlocBase<STATE, EFFECT> {
  SafeCubitWithPresentation(super.initialState);

  /// Wraps a cubit callback in try-catch block and processes them based on specified parameters.
  ///  - [devErrorMessage] - A string message that is passes to UnexpectedError object in emitted event or state.
  ///  - [isAction] - If set to true, the passed `callback` is a user action (e.g button pressing). If set to false(default), the `callback` is a initial data loading.
  ///  - [ignoreError]  - Bool that indicates whether the exception should be ignored. If set to `true`, the exception is caught, but no error state is emitted.
  ///  - [onIgnoreError] - A callback that is invoked if the exception in the `callback` occurs and `ignoreError` parameter is set to `true`.
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
