import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../services/hive_service.dart';

class RegistrationProvider extends ChangeNotifier {
  List<RegistrationModel> _registrations = [];

  List<RegistrationModel> get registrations => _registrations;

  Future<void> initialize() async {
    _registrations = HiveService.getRegistrations();
    notifyListeners();
  }

  bool isRegistered({required String eventId, required String userEmail}) {
    final normalizedEmail = userEmail.trim().toLowerCase();
    return _registrations.any(
      (item) => item.eventId == eventId && item.userEmail.toLowerCase() == normalizedEmail,
    );
  }

  int registrationsCountForEvent(String eventId) {
    return _registrations.where((item) => item.eventId == eventId).length;
  }

  Future<String?> registerToEvent({
    required EventModel event,
    required String userEmail,
    String? registrationKeyInput,
  }) async {
    final normalizedEmail = userEmail.trim().toLowerCase();

    if (!event.isPublished!) {
      return 'This event is not published yet.';
    }

    if (event.requiresSecureKey) {
      final input = (registrationKeyInput ?? '').trim();
      if (input.isEmpty) return 'Please enter the 6-digit registration key.';
      if (event.registrationKey == null) {
      return 'This event is misconfigured (missing registration key).';
      }
      if (input != event.registrationKey) {
        return 'Invalid registration key.';
      }
    }

    if (isRegistered(eventId: event.id, userEmail: normalizedEmail)) {
      return 'You are already registered for this event.';
    }

    if (registrationsCountForEvent(event.id) >= event.maxCapacity) {
      return 'Event capacity is full.';
    }

    final registration = RegistrationModel(
      id: const Uuid().v4(),
      eventId: event.id,
      eventName: event.eventName,
      userEmail: normalizedEmail,
      registeredAt: DateTime.now(),
    );

    await HiveService.addRegistration(registration);
    _registrations = HiveService.getRegistrations();
    notifyListeners();
    return null;
  }

  List<RegistrationModel> myRegistrations(String userEmail) {
    final normalizedEmail = userEmail.trim().toLowerCase();
    final list = _registrations
        .where((item) => item.userEmail.toLowerCase() == normalizedEmail)
        .toList(growable: false);
    list.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return list;
  }

  List<RegistrationModel> searchLogs(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _registrations;
    return _registrations.where((item) {
      return item.eventName.toLowerCase().contains(q) ||
          item.userEmail.toLowerCase().contains(q) ||
          item.eventId.toLowerCase().contains(q);
    }).toList(growable: false);
  }
}
