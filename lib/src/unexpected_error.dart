/// Object that stores information about exceptions thrown in Blocs and Cubits.
class UnexpectedError {
  // Thrown exception
  // Exception or Error has unknown type
  // ignore: avoid-dynamic
  final dynamic error;

  // Exception stacktrace
  final StackTrace stackTrace;

  // Additional info message about the exception
  final String? devMessage;

  // specifies if exception was thrown during the initial data loading (`false`) or during the user action (`true`)
  final bool isAction;

  const UnexpectedError({
    required this.error,
    required this.stackTrace,
    this.devMessage,
    this.isAction = false,
  });

  @override
  String toString() => 'UnexpectedError: error. ${devMessage ?? ''}';
}

/// API that is implemented by Bloc/Cubit's error states and effects.
abstract class UnexpectedErrorBase {
  UnexpectedError get error;

  const UnexpectedErrorBase();
}
