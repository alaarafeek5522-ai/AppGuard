import 'package:flutter/material.dart';
import 'screens/guard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppGuard());
}

class AppGuard extends StatelessWidget {
  const AppGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GuardScreen(
        child: const _HomeScreen(),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          '✅ App Verified',
          style: TextStyle(color: Color(0xFF00FF88), fontSize: 24),
        ),
      ),
    );
  }
}
