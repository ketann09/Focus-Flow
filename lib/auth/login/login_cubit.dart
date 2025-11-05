import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:focus_flow/auth/bloc/auth_bloc.dart'; 
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuth _firebaseAuth;
  final AuthBloc _authBloc; 

  LoginCubit(this._authBloc, {FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(LoginInitial());

  void login(String email, String password) async {
    emit(LoginLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _authBloc.add(LoggedIn()); 
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'Login failed. Please try again.'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  void signup(String email, String password) async {
    emit(LoginLoading());
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _authBloc.add(LoggedIn());
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'Sign up failed. Please try again.'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
  void signInWithGoogle() async {
    emit(LoginLoading());
    try {
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        
        emit(LoginInitial());
        return;
      }

      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      _authBloc.add(LoggedIn());
      emit(LoginSuccess());

    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'Sign-in failed.'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}