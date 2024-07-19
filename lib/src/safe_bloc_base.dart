import 'dart:async';
import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/src/unexpected_error.dart';
import 'package:trackable/trackable.dart';

export 'package:bloc/bloc.dart' show Emitter;

abstract class SafeBlocBase<STATE, EFFECT> extends BlocBase<STATE>
    with SafeBlocBaseMixin<STATE, EFFECT>, BlocPresentationMixin<STATE, EFFECT> {
  SafeBlocBase(super._state);

  /// A method that is called each time the exception in the inherited Bloc or Cubit is thrown.
  @protected
  Future<void> onUnexpectedError(Object? error, StackTrace stackTrace, String trackingId) {
    return Future.value();
  }
}

typedef ErrorStateGetter<STATE> = STATE Function(UnexpectedError error);

typedef ErrorEffectGetter<EFFECT> = EFFECT Function(UnexpectedError error);

typedef Emit<STATE> = void Function(STATE state);

typedef InvokeEffect<EFFECT> = void Function(EFFECT effect);

typedef Callback = Future<void> Function(String trackingId);

typedef SyncCallback = void Function(String trackingId);

typedef OnIgnoreError = Future<void> Function(Object? error, StackTrace stackTrace);

typedef OnError = Future<void> Function(Object? error, StackTrace stackTrace, String trackingId);

typedef OnErrorSync = void Function(Object? error, StackTrace stackTrace, String trackingId);

typedef ErrorMapper<STATE> = STATE? Function(Object error);

mixin SafeBlocBaseMixin<STATE, EFFECT> on BlocBase<STATE> {
  /// Returns an instance of state that is emitted if exception in callback occurs and
  /// the callback represents an initial data loading (`isAction` parameter `is false`).
  @protected
  ErrorStateGetter<STATE> get errorState;

  /// Returns an instance of effect that is emitted if exception in callback occurs
  /// and the callback represents an user action (`isAction` parameter is `true`).
  @protected
  ErrorEffectGetter<EFFECT> get errorEffect;

  /// Wraps a cubit callback in try-catch block and processes them based on specified parameters.
  @internal
  Future<void> safeCallInternal(
    Emit<STATE> emit,
    Callback callback, {
    required InvokeEffect<EFFECT> invokeActionSideEffect,
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    OnIgnoreError? onIgnoreError,
    OnError? onError,
    ErrorMapper<STATE>? errorMapper,
  }) async {
    final trackingId = TrackingIdService.createTrackingId();

    try {
      await callback(trackingId);
    }
    // ignore: avoid_catches_without_on_clauses, catch them all
    catch (e, stacktrace) {
      await onError?.call(e, stacktrace, trackingId);
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');

      if (ignoreError) {
        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return await onIgnoreError?.call(e, stacktrace);
      }

      final error = UnexpectedError(
        error: e,
        stackTrace: stacktrace,
        devMessage: devErrorMessage,
        isAction: isAction,
        trackingId: trackingId,
      );

      final resultingErrorState = errorMapper?.call(e);

      if (isAction && resultingErrorState == null) {
        invokeActionSideEffect(errorEffect(error));

        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return;
      }

      emit(resultingErrorState ?? errorState(error));

      // * In test environment we want to exception to propagate outside
      if (isTest) rethrow;
    }
  }

  /// Synchronous version of [safeCallInternal] method.
  @internal
  void safeCallInternalSync(
    Emit<STATE> emit,
    SyncCallback callback, {
    required InvokeEffect<EFFECT> invokeActionSideEffect,
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    OnIgnoreError? onIgnoreError,
    OnErrorSync? onError,
    ErrorMapper<STATE>? errorMapper,
  }) =>
      unawaited(
        safeCallInternal(
          emit,
          (trackingId) {
            callback(trackingId);

            return Future.value();
          },
          invokeActionSideEffect: invokeActionSideEffect,
          devErrorMessage: devErrorMessage,
          isAction: isAction,
          ignoreError: ignoreError,
          onIgnoreError: (error, stackTrace) {
            onIgnoreError?.call(error, stackTrace);

            return Future.value();
          },
          onError: (error, stackTrace, trackingId) {
            onError?.call(error, stackTrace, trackingId);

            return Future.value();
          },
          errorMapper: errorMapper,
        ),
      );
}
