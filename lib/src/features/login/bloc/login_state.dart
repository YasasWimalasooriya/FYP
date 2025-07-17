part of 'login_bloc.dart';

@immutable
sealed class LoginState {}
abstract class LoginActionState extends LoginState{}
final class LoginInitial extends LoginState {}

class EvOwnerClickedState extends LoginState{}
class SystemOperatorClickedState extends LoginState{}
