import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'event_setup_screen.dart';
import 'home_screen.dart';
import 'logs_screen.dart';
import 'my_events_screen.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    final screens = isAdmin
        ? <Widget>[
            const HomeScreen(isAdmin: true),
            const EventSetupScreen(),
            const LogsScreen(),
          ]
        : <Widget>[
            const HomeScreen(isAdmin: false),
            const MyEventsScreen(),
          ];

    final titles = isAdmin
        ? const ['Home', 'Add Event', 'Logs']
        : const ['Home', 'My Events'];

    final items = isAdmin
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Event'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Logs'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'My Events'),
          ];

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1463FF),
        items: items,
      ),
    );
  }
}
