// ignore_for_file: prefer-static-class, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, depend_on_referenced_packages

import 'dart:async';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:test/test.dart' as test;

@isTest
void blocPresentationTest<B extends BlocPresentationMixin<State, BaseEffect>, State>(
  String description, {
  required B Function() build,
  FutureOr<void> Function()? setUp,
  State Function()? seed,
  FutureOr<void> Function(B bloc)? act,
  Duration? wait,
  int skip = 0,
  List<State> Function()? expect,
  FutureOr<void> Function(B bloc)? verify,
  test.Matcher Function()? errors,
  FutureOr<void> Function()? tearDown,
  Object? tags,
  List<BaseEffect> Function()? expectEvents,
}) {
  test.test(
    description,
    () async {
      await testBloc<B, State>(
        setUp: setUp,
        build: build,
        seed: seed,
        act: act,
        wait: wait,
        skip: skip,
        expect: expect,
        verify: verify,
        errors: errors,
        tearDown: tearDown,
        expectEvents: expectEvents,
      );
    },
    tags: tags,
  );
}

/// Internal [blocPresentationTest] runner which is only visible for testing.
/// This should never be used directly -- please use [blocPresentationTest] instead.
@visibleForTesting
Future<void> testBloc<B extends BlocPresentationMixin<State, BaseEffect>, State>({
  required B Function() build,
  FutureOr<void> Function()? setUp,
  State Function()? seed,
  FutureOr<void> Function(B bloc)? act,
  Duration? wait,
  int skip = 0,
  List<State> Function()? expect,
  FutureOr<void> Function(B bloc)? verify,
  test.Matcher Function()? errors,
  FutureOr<void> Function()? tearDown,
  List<BaseEffect> Function()? expectEvents,
}) async {
  var shallowEquality = false;
  final unhandledErrors = <Object>[];
  final localBlocObserver = Bloc.observer;
  final testObserver = _TestBlocObserver(
    localBlocObserver,
    unhandledErrors.add,
  );
  Bloc.observer = testObserver;

  await runZonedGuarded(
    () async {
      await setUp?.call();
      final states = <State>[];
      final events = <BaseEffect>[];
      final bloc = build();
      if (seed != null) bloc.emit(seed());
      final subscription = bloc.stream.skip(skip).listen(states.add);
      final eventsSubscription = bloc.presentation.listen(events.add);
      try {
        await act?.call(bloc);
        // Ignored in order to capture also Error types.
        // ignore: avoid_catches_without_on_clauses
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      if (expect != null) {
        final expected = expect();
        shallowEquality = '$states' == '$expected';
        try {
          test.expect(states, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality) rethrow;
          final diff = _diff(expected: expected, actual: states);
          final message = '${e.message}\n$diff';
          // Stacktrace not needed in test.
          // ignore: avoid-throw-in-catch-block
          throw test.TestFailure(message);
        }
      }

      if (expectEvents != null) {
        final expectedEvents = expectEvents();
        shallowEquality = '$events' == '$expectedEvents';
        try {
          test.expect(events, test.wrapMatcher(expectedEvents));
        } on test.TestFailure catch (e) {
          if (shallowEquality) rethrow;
          final diff = _diff(expected: expectedEvents, actual: events);
          final message = '${e.message}\n$diff';
          // Stacktrace not needed in test.
          // ignore: avoid-throw-in-catch-block
          throw test.TestFailure(message);
        }
      }
      await subscription.cancel();
      await eventsSubscription.cancel();
      await verify?.call(bloc);
      await tearDown?.call();
    },
    (error, _) {
      if (shallowEquality && error is test.TestFailure) {
        throw test.TestFailure(
          '''
          ${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the blocTest rather than concrete state instances.\n''',
        );
      }
      if (errors == null || !unhandledErrors.contains(error)) {
        if (error is Exception) {
          throw error;
        } else if (error is Error) {
          throw error;
        }
      }
    },
  );
  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}

class _TestBlocObserver extends BlocObserver {
  final BlocObserver _localObserver;
  final void Function(Object error) _onError;

  const _TestBlocObserver(this._localObserver, this._onError);

  @override
  // Overrides method from external library.
  // ignore: strict_raw_type
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _localObserver.onError(bloc, error, stackTrace);
    _onError(error);
    super.onError(bloc, error, stackTrace);
  }
}

String _diff<State>({required List<State> expected, required List<State> actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());
  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln()
    ..writeln(differences.toPrettyString())
    ..writeln()
    ..writeln('${"=" * 4} end diff ${"=" * 36}');

  return buffer.toString();
}

extension on List<Diff> {
  String toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
      }
    }

    return buffer.toString();
  }
}
