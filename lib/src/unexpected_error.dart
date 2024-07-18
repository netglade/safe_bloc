import 'package:trackable/trackable.dart';

/// Object that stores information about exceptions thrown in Blocs and Cubits.
class UnexpectedError extends GeneralTrackableError {
  // Exception stacktrace
  final StackTrace stackTrace;

  // Additional info message about the exception
  final String? devMessage;

  // specifies if exception was thrown during the initial data loading (`false`) or during the user action (`true`)
  final bool isAction;

  UnexpectedError({
    required super.error,
    required this.stackTrace,
    required super.trackingId,
    this.devMessage,
    this.isAction = false,
  }) : super(errorId: ErrorIdService.get());

  @override
  String toString() => 'UnexpectedError: error. ${devMessage ?? ''}. ErrorId: $errorId';
}

/// API that is implemented by Bloc/Cubit's error states and effects.
abstract class UnexpectedErrorBase {
  UnexpectedError get error;

  const UnexpectedErrorBase();
}
