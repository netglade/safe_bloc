import 'dart:async';
import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/src/base_effect.dart';
import 'package:safe_bloc/src/tracking_id_service.dart';
import 'package:safe_bloc/src/unexpected_error.dart';

export 'package:bloc/bloc.dart' show Emitter;

abstract class SafeBlocBase<STATE> extends BlocBase<STATE>
    with SafeBlocBaseMixin<STATE>, BlocPresentationMixin<STATE, BaseEffect> {
  SafeBlocBase(super._state);

  /// A method that is called each time the exception in the inherited Bloc or Cubit is thrown.
  @protected
  FutureOr<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) {
    return Future.value();
  }
}

mixin SafeBlocBaseMixin<STATE> on BlocBase<STATE> {
  /// Returns an instance of state that is emitted if exception in callback occurs and
  /// the callback represents an initial data loading (`isAction` parameter `is false`).
  @protected
  STATE Function(UnexpectedError error) get errorState;

  /// Returns an instance of effect that is emitted if exception in callback occurs
  /// and the callback represents an user action (`isAction` parameter is `true`).
  @protected
  BaseEffect Function(UnexpectedError) get errorEffect => UnexpectedErrorEffect.new;

  /// Wraps a cubit callback in try-catch block and processes them based on specified parameters.
  @internal
  Future<void> safeCallInternal(
    void Function(STATE state) emit,
    FutureOr<void> Function(String trackingId) callback, {
    required FutureOr<void> Function(BaseEffect effect) invokeActionSideEffect,
    String? devErrorMessage,
    bool isAction = false,
    bool ignoreError = false,
    FutureOr<void> Function(Object? error, StackTrace stackTrace)? onIgnoreError,
    FutureOr<void> Function(Object? error, StackTrace stackTrace, String? trackingId)? onError,
  }) async {
    final trackingId = TrackingIdService.createTrackingId();

    try {
      await callback(trackingId);
    }
    // ignore: avoid_catches_without_on_clauses, catch them all
    catch (e, stacktrace) {
      onError?.call(e, stacktrace, trackingId);
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');

      if (ignoreError) {
        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return onIgnoreError?.call(e, stacktrace);
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
}
