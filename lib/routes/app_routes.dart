import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/event_setup_screen.dart';
import '../screens/main_nav_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String eventSetup = '/event-setup';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        eventSetup: (_) => const EventSetupScreen(),
        dashboard: (_) => const MainNavShell(),
      };
}
