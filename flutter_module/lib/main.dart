import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'create_user_screen.dart';
import 'users_screen.dart';

void main() => runApp(const FlutterModuleApp());

class FlutterModuleApp extends StatefulWidget {
  const FlutterModuleApp({super.key});

  @override
  State<FlutterModuleApp> createState() => _FlutterModuleAppState();
}

class _FlutterModuleAppState extends State<FlutterModuleApp> {
  // Same channel as iOS UsersBridgeChannel — host pushes
  // `presentRoute` calls in to switch which screen we show.
  static const _hostChannel = MethodChannel('com.huh.nativeflutter/users');

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _hostChannel.setMethodCallHandler(_handleHostCall);
  }

  Future<dynamic> _handleHostCall(MethodCall call) async {
    if (call.method == 'presentRoute') {
      final route = call.arguments as String? ?? 'users';
      _routeTo(route);
    }
    return null;
  }

  void _routeTo(String route) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;
    // Drop any previous-session screens so route changes are deterministic.
    nav.popUntil((r) => r.isFirst);
    if (route == 'create') {
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => const CreateUserScreen(popOnSave: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Module',
      navigatorKey: _navigatorKey,
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
