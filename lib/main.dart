import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/landing_page.dart';

void main() {
  runApp(const KarigarApp());
}

class KarigarApp extends StatelessWidget {
  const KarigarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karigar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const AppInitializer(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/landing': (context) => const LandingPage(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash wait
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    } else {
      return const LoginScreen(); // Go to Login after Splash
    }
  }
}
