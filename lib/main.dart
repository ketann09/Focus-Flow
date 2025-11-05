import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/auth/bloc/auth_bloc.dart';
import 'package:focus_flow/home/home_screen.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'firebase_options.dart';
import 'package:focus_flow/auth/screens/login_screen.dart';
import 'package:focus_flow/repositories/task_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal; 
    final Color backgroundColor = Color(0xfff0f4f8);
    final Color darkTextColor = Color(0xff1a252f); 
    return BlocProvider(
      create: (context) => AuthBloc()..add(AppStarted()),

      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => TaskRepository()),
          RepositoryProvider(create: (context) => SessionRepository()),
        ],

        child: MaterialApp(
          title: 'FocusFlow',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: backgroundColor,
            
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
              surface: backgroundColor,
              primary: primaryColor,
            ),

            // Define text styles
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
              ),
              headlineSmall: TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(
                color: darkTextColor.withAlpha(204),
                fontSize: 16,
              ),
            ),

            // Define button themes
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Define input field themes
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelStyle: TextStyle(color: darkTextColor.withAlpha(153)),
            ),

            // Define card themes
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Define bottom nav bar theme
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey[400],
              type: BottomNavigationBarType.fixed,
              elevation: 0,
            ),

            // Define app bar theme
            appBarTheme: AppBarTheme(
              backgroundColor: backgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: darkTextColor),
              titleTextStyle: TextStyle(
                color: darkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
