import 'package:safe_bloc/src/unexpected_error.dart';

abstract class BaseEffect {}

class UnexpectedErrorEffect extends BaseEffect implements UnexpectedErrorAPI {
  @override
  final UnexpectedError error;

  UnexpectedErrorEffect(this.error);
}
