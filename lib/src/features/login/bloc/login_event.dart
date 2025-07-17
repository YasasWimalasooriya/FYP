part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class EvOwnerButtonClickedEvent extends LoginEvent{}
class SystemOperatorButtonClickedEvent extends LoginEvent{}