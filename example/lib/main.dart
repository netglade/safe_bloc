import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

/// Flutter Counter app that stores the count to shared preferences and loads it back at the app start.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CounterBloc>(
          create: (_) => CounterBloc()..add(LoadCounter()),
          child: const CounterView(),
        ),
      ),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: UnexpectedErrorHandler<CounterBloc, CounterState>(
          child: BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              if (state is! CounterLoaded) return const CircularProgressIndicator();

              return Text(state.count.toString(), style: textTheme.displayMedium);
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => context.read<CounterBloc>().add(IncrementPressed()),
          ),
        ],
      ),
    );
  }
}

sealed class CounterEvent {}

final class IncrementPressed extends CounterEvent {}

final class LoadCounter extends CounterEvent {}

sealed class CounterState {}

final class CounterLoading extends CounterState {}

final class CounterLoaded extends CounterState {
  final int count;

  CounterLoaded({required this.count});
}

final class CounterBlocError extends CounterState implements UnexpectedErrorBase {
  @override
  final UnexpectedError error;

  CounterBlocError(this.error);
}

class CounterBloc extends SafeBloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterLoading()) {
    // `isAction` parameter is set to false for initial data loading
    onSafe<LoadCounter>(_loadCounter, isAction: false);

    // `isAction` parameter is set to true for user action
    onSafe<IncrementPressed>(_increment, isAction: true);
  }

  Future<void> _increment(
    IncrementPressed event,
    SafeEmitter<CounterState> emit, {
    required String trackingId,
  }) async {
    if (state case final CounterLoaded loaded) {
      final incrementedCount = loaded.count + 1;

      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('count_key', incrementedCount);

      // uncomment the exception throwing to test the error dialog
      // throw Exception("Something wrong happened");

      emit(CounterLoaded(count: incrementedCount));
    }
  }

  Future<void> _loadCounter(LoadCounter event, SafeEmitter<CounterState> emit, {required String trackingId}) async {
    final preferences = await SharedPreferences.getInstance();
    final count = preferences.get('count_key') as int?;

    // uncomment the exception throwing to test the error screen
    // throw Exception("Something wrong happened when counter loading");

    emit(CounterLoaded(count: count ?? 0));
  }

  @override
  CounterState Function(UnexpectedError error) get errorState => CounterBlocError.new;

  @override
  Future<void> onUnexpectedError(Object? error, StackTrace stackTrace, String? trackingId) async {
    if (kDebugMode) {
      print('Exception: $error, $stackTrace');
    }
  }
}
