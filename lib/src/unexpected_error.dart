class UnexpectedError {
  final dynamic error;
  final StackTrace stackTrace;
  final String? devMessage;
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

abstract class UnexpectedErrorAPI {
  UnexpectedError get error;
}
