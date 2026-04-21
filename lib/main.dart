import 'package:flutter/material.dart';
import 'screens/HomeScreen.dart';

void main() => runApp(NavManager());

class NavManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/onboarding', // o '/' si ya completó onboarding
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home':       (_) => const HomeScreen(),
      },
    );
  }
}
