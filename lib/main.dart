import 'package:expense_user/services/auth_service.dart';
import 'package:expense_user/view_models/auth_view_model.dart';
import 'package:expense_user/views/auth/login_screen.dart';
import 'package:expense_user/views/main_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Entry point
Future<void> main() async {
  // bindings before initialization.
  WidgetsFlutterBinding.ensureInitialized();
  // services.
  await Firebase.initializeApp();
  // Launch
  runApp(const MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const SystemUiOverlayStyle _systemUiOverlayStyle =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (BuildContext context) {
        return AuthViewModel();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _systemUiOverlayStyle,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense User',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: _systemUiOverlayStyle,
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

// login screen or the main app
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() {
    return _AuthGateState();
  }
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    AuthViewModel vm = context.watch<AuthViewModel>();

    //  loading spinner
    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Listen to Firebase auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // Show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in
        User? user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // before showing the main app.
        return FutureBuilder<void>(
          future: _authService.ensureUserProfile(user),
          builder: (BuildContext context, AsyncSnapshot<void> profileSnapshot) {
            // Show loading
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If profile creation failed
            if (profileSnapshot.hasError) {
              return const LoginScreen();
            }

            // main app.
            return const MainWrapper();
          },
        );
      },
    );
  }
}