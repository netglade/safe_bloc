import 'package:safe_bloc/src/base_effect.dart';
import 'package:safe_bloc/src/safe_bloc_base.dart';
import 'package:safe_bloc/src/safe_bloc_with_presentation.dart';

/// An extended class to [SafeBlocWithPresentation] that uses [BaseEffect] class as EFFECT.
/// Additionally, it also emits an [UnexpectedErrorEffect] if exception occurs during some use action.
abstract class SafeBloc<EVENT, STATE> extends SafeBlocWithPresentation<EVENT, STATE, BaseEffect> {
  @override
  ErrorEffectGetter<BaseEffect> get errorEffect => UnexpectedErrorEffect.new;

  SafeBloc(super.initialState);
}
