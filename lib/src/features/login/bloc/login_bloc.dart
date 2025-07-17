import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<EvOwnerButtonClickedEvent>(evOwnerButtonClickedEvent);
    on<SystemOperatorButtonClickedEvent>(systemOperatorButtonClickedEvent);
  }

  FutureOr<void> evOwnerButtonClickedEvent(EvOwnerButtonClickedEvent event, Emitter<LoginState> emit) {
    emit(
      EvOwnerClickedState()
    );
  }

  FutureOr<void> systemOperatorButtonClickedEvent(SystemOperatorButtonClickedEvent event, Emitter<LoginState> emit) {
    emit(
      SystemOperatorClickedState()
    );
  }
}
