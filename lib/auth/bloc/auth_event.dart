part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Fired when the app starts to check auth status
class AppStarted extends AuthEvent {}

// Fired when the user successfully logs in
class LoggedIn extends AuthEvent {}

// Fired when the user logs out
class LoggedOut extends AuthEvent {}