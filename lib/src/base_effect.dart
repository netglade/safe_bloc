import 'package:safe_bloc/src/unexpected_error.dart';

/// General parent effect.
abstract class BaseEffect {
  const BaseEffect();
}

/// Error effect that is emitted by `SafeBloc`/`SafeCubit` if exception in its event handler/method occurs.
class UnexpectedErrorEffect extends BaseEffect implements UnexpectedErrorBase {
  @override
  final UnexpectedError error;

  const UnexpectedErrorEffect(this.error);
}
