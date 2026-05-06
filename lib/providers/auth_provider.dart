import 'package:flutter/material.dart';

enum UserRole { admin, user }

class AuthProvider extends ChangeNotifier {
  static const String _adminEmail = 'rajan@charusat.ac.in';
  static const String _adminPassword = '12345678';

  String? _email;
  UserRole? _role;

  String? get email => _email;
  UserRole? get role => _role;
  bool get isLoggedIn => _role != null;
  bool get isAdmin => _role == UserRole.admin;
  bool get isUser => _role == UserRole.user;

  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Email and password are required.';
    }

    if (!_isValidEmail(normalizedEmail)) {
      return 'Enter a valid email address.';
    }

    if (normalizedEmail == _adminEmail) {
      if (trimmedPassword != _adminPassword) {
        return 'Invalid admin password.';
      }
      _email = normalizedEmail;
      _role = UserRole.admin;
      notifyListeners();
      return null;
    }

    if (!normalizedEmail.endsWith('@charusat.ac.in')) {
      return 'Only @charusat.ac.in email addresses are allowed.';
    }

    if (trimmedPassword.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    _email = normalizedEmail;
    _role = UserRole.user;
    notifyListeners();
    return null;
  }

  void logout() {
    _email = null;
    _role = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}
