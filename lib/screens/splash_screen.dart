import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _bootstrap() async {
    final eventProvider = context.read<EventProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    await eventProvider.initialize();
    await attendanceProvider.initialize();

    if (!mounted) return;

    final nextRoute = eventProvider.hasEvent ? AppRoutes.dashboard : AppRoutes.eventSetup;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      _bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF1463FF)),
            const SizedBox(height: 24),
            Text(
              'Smart Event Check-in',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F3B85),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Crowd Management',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
