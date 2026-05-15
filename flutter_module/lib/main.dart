import 'package:flutter/material.dart';
import 'users_screen.dart';

void main() => runApp(const FlutterModuleApp());

class FlutterModuleApp extends StatelessWidget {
  const FlutterModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Module',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: const Color(0xFF0468D7),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
          bodyMedium: TextStyle(color: Color(0xFF4B5563)),
        ),
      ),
      home: const UsersScreen(),
    );
  }
}
