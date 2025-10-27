part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

// Initial state, show a loading spinner
class AuthInitial extends AuthState {}

// User is logged in
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

// User is not logged in
class Unauthenticated extends AuthState {}