import 'package:flutter/material.dart';
import 'screens/HomeScreen.dart';
import 'screens/OnBoarding.dart';

void main() {
  runApp(NavManager());
}

/*Nav Manager*/
class NavManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/onboarding', //TODO cambiar a que cheque si ya terminó OnBoarding
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home':       (_) => const HomeScreen(),
      },
    );
  }
}