import 'package:safe_bloc/src/unexpected_error.dart';

abstract class BaseState {}

class UnexpectedErrorState extends BaseState implements UnexpectedErrorAPI {
  @override
  final UnexpectedError error;

  UnexpectedErrorState(this.error);
}
