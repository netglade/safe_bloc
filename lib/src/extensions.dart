// ignore_for_file: prefer-match-file-name

import 'package:bloc/bloc.dart';

/// Calls emit only and only if underlying bloc is not closed.
///
/// * Current "safe workaround" until https://github.com/felangel/bloc/issues/3069 is merged.
extension CubitExtensions<State> on Cubit<State> {
  void safeEmit(State state) {
    if (isClosed) return;

    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, it is ok
    emit(state);
  }
}
