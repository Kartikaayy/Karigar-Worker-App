import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5), // Light lavender tone
              Color(0xFFFFFFFF), // Pure white for soft transition
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/mp_logo.png', height: 120),
              const SizedBox(height: 20),
              DefaultTextStyle(
                style: GoogleFonts.lato(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText('Karigar'),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'MP Government Services',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.deepPurple.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
