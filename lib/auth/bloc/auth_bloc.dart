import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) { // The BLoC starts in the 'AuthInitial' state
    
    // When the AppStarted event is fired
    on<AppStarted>((event, emit) async {
      try {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          // User is logged in
          emit(Authenticated(user));
        } else {
          // User is not logged in
          emit(Unauthenticated());
        }
      } catch (_) {
        emit(Unauthenticated());
      }
    });

    // When the LoggedIn event is fired
    on<LoggedIn>((event, emit) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        // This case should not really happen, but good to handle
        emit(Unauthenticated());
      }
    });

    // When the LoggedOut event is fired
    on<LoggedOut>((event, emit) async {
      await _firebaseAuth.signOut();
      emit(Unauthenticated());
    });
  }
}