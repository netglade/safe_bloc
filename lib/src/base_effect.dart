import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:safe_bloc/src/unexpected_error.dart';

abstract class BaseEffect implements BlocPresentationEvent {}

class UnexpectedErrorEffect extends BaseEffect implements UnexpectedErrorAPI {
  @override
  final UnexpectedError error;

  UnexpectedErrorEffect(this.error);
}
