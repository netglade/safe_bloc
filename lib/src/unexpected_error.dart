import 'package:bloc_presentation/bloc_presentation.dart';

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

abstract class UnexpectedErrorAPI implements BlocPresentationEvent {
  UnexpectedError get error;
}
