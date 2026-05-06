import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'checkin_screen.dart';
import 'logs_screen.dart';
import '../routes/app_routes.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CheckinScreen(),
    LogsScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Participant Check-in',
    'Check-in Logs',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Event Setup',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.eventSetup),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1463FF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
