import 'dart:async';
import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/src/tracking_id_service.dart';
import 'package:safe_bloc/src/unexpected_error.dart';

export 'package:bloc/bloc.dart' show Emitter;

abstract class SafeBlocBase<STATE, EFFECT> extends BlocBase<STATE>
    with SafeBlocBaseMixin<STATE, EFFECT>, BlocPresentationMixin<STATE, EFFECT> {
  SafeBlocBase(super._state);

  /// A method that is called each time the exception in the inherited Bloc or Cubit is thrown.
  @protected
  Future<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) {
    return Future.value();
  }
}

mixin SafeBlocBaseMixin<STATE, EFFECT> on BlocBase<STATE> {
  /// Returns an instance of state that is emitted if exception in callback occurs and
  /// the callback represents an initial data loading (`isAction` parameter `is false`).
  @protected
  STATE Function(UnexpectedError error) get errorState;

  /// Returns an instance of effect that is emitted if exception in callback occurs
  /// and the callback represents an user action (`isAction` parameter is `true`).
  @protected
  EFFECT Function(UnexpectedError) get errorEffect;

  /// Wraps a cubit callback in try-catch block and processes them based on specified parameters.
  @internal
  Future<void> safeCallInternal(
    void Function(STATE state) emit,
    Future<void> Function(String trackingId) callback, {
    required void Function(EFFECT effect) invokeActionSideEffect,
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    Future<void> Function(Object? error, StackTrace stackTrace)? onIgnoreError,
    Future<void> Function(Object? error, StackTrace stackTrace, String? trackingId)? onError,
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

      final error = UnexpectedError(error: e, stackTrace: stacktrace, devMessage: devErrorMessage, isAction: isAction);

      if (isAction) {
        invokeActionSideEffect(errorEffect(error));

        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return;
      }

      emit(errorState(error));

      // * In test environment we want to exception to propagate outside
      if (isTest) rethrow;
    }
  }

 /// Synchronous version of [safeCallInternal] method.
 @internal
  void safeCallInternalSync(
    void Function(STATE state) emit,
    void Function(String trackingId) callback, {
    required void Function(EFFECT effect) invokeActionSideEffect,
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    void Function(Object? error, StackTrace stackTrace)? onIgnoreError,
    void Function(Object? error, StackTrace stackTrace, String? trackingId)? onError,
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
        ),
      );
}
