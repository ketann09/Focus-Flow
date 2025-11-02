import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/auth/bloc/auth_bloc.dart'; 
import 'package:focus_flow/home/home_screen.dart'; 
import 'firebase_options.dart';
import 'package:focus_flow/auth/screens/login_screen.dart'; 
import 'package:focus_flow/repositories/task_repository.dart'; // Make sure this is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(AppStarted()), 
      
      // *** THIS IS THE FIX ***
      // We provide the TaskRepository to the whole app,
      // so the TaskBloc can find it.
      child: RepositoryProvider(
        create: (context) => TaskRepository(),
        child: MaterialApp(
          title: 'FocusFlow',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        }
        if (state is Unauthenticated) {
          return const LoginScreen();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}