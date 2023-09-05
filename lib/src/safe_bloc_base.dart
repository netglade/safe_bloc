import 'dart:async';
import 'dart:io';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/src/base_effect.dart';
import 'package:safe_bloc/src/tracking_id_service.dart';
import 'package:safe_bloc/src/unexpected_error.dart';

export 'package:bloc/bloc.dart' show Emitter;

abstract class SafeBlocBase<STATE> extends BlocBase<STATE> with SafeBlocBaseMixin<STATE>, BlocPresentationMixin<STATE, BaseEffect> {
  SafeBlocBase(super._state);

  @protected
  FutureOr<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) {
    return Future.value();
  }
}

mixin SafeBlocBaseMixin<STATE> on BlocBase<STATE> {
  @protected
  STATE Function(UnexpectedError error) get errorState;

  @protected
  BaseEffect Function(UnexpectedError) get errorEffect => UnexpectedErrorEffect.new;

  @internal
  FutureOr<void> safeCallInternal(
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
      //  logger.error((message ?? 'Unexpected error occurred in cubit $runtimeType').tracked(trackingId), e, stacktrace);
      onError?.call(e, stacktrace, trackingId);
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');

      if (ignoreError) {
        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return onIgnoreError?.call(e, stacktrace);
      }

      final error = UnexpectedError(error: e, stackTrace: stacktrace, devMessage: devErrorMessage, isAction: isAction);

      if (isAction) {
        // produceSideEffect(errorEffect.call(error));
        invokeActionSideEffect(errorEffect.call(error));

        // * In test environment we want to exception to propagate outside
        if (isTest) rethrow;

        return;
      }

      emit(errorState.call(error));

      // * In test environment we want to exception to propagate outside
      if (isTest) rethrow;
    }
  }
}
