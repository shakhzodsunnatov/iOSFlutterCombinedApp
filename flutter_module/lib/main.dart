// flutter_module entry point.
//
// This is the default "welcome" screen the Flutter dev will see
// when the iOS host pushes the Flutter view. Replace with the real
// bridge demo from the host project's README.md when ready.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Channel name matches the iOS UsersBridgeChannel — used here only
  // to dismiss the Flutter screen back to SwiftUI.
  static const _bridge = MethodChannel('com.huh.nativeflutter/users');

  Future<void> _closeFlutter() async {
    try {
      await _bridge.invokeMethod('closeFlutter');
    } catch (_) {
      // Host hasn't wired the channel yet — silently ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const _FlutterMark(),
              const SizedBox(height: 32),
              Text(
                'Welcome to Flutter',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are inside an embedded Flutter view running\n'
                'on top of the native iOS host app.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.45,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _closeFlutter,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to iOS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlutterMark extends StatelessWidget {
  const _FlutterMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F0FB),
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.flutter_dash,
          size: 56,
          color: Color(0xFF0468D7),
        ),
      ),
    );
  }
}
