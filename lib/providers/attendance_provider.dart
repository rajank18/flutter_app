import 'package:flutter/material.dart';
import '../models/checkin_model.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';
import '../services/hive_service.dart';
import '../services/validation_service.dart';

class CheckInResult {
  final bool success;
  final String message;

  const CheckInResult({required this.success, required this.message});
}

class AttendanceProvider extends ChangeNotifier {
  List<ParticipantModel> _participants = [];
  List<CheckinModel> _checkins = [];

  List<ParticipantModel> get participants => _participants;
  List<CheckinModel> get checkins => _checkins;

  Future<void> initialize() async {
    _participants = HiveService.getParticipants();
    _checkins = HiveService.getCheckins();
    notifyListeners();
  }

  int checkedInCount() => _checkins.length;

  int remainingCapacity(EventModel? event) {
    if (event == null) return 0;
    final remaining = event.maxCapacity - checkedInCount();
    return remaining < 0 ? 0 : remaining;
  }

  List<CheckinModel> filteredLogs(String query) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) return _checkins;

    return _checkins.where((log) {
      return log.participantId.toUpperCase().contains(q) ||
          log.participantName.toUpperCase().contains(q);
    }).toList(growable: false);
  }

  Future<CheckInResult> checkInParticipant({
    required String participantRawId,
    required EventModel? event,
  }) async {
    final participantValidation = ValidationService.validateParticipantId(participantRawId);
    if (participantValidation != null) {
      return CheckInResult(success: false, message: participantValidation);
    }

    if (event == null) {
      return const CheckInResult(success: false, message: 'Create an event first.');
    }

    final participantId = ValidationService.normalizeParticipantId(participantRawId);

    final participant = _participants.where((p) => p.id.toUpperCase() == participantId).cast<ParticipantModel?>().firstWhere(
          (p) => p != null,
          orElse: () => null,
        );

    if (participant == null) {
      return const CheckInResult(success: false, message: 'Invalid participant ID.');
    }

    final isDuplicate = _checkins.any((item) => item.participantId.toUpperCase() == participantId);
    if (isDuplicate) {
      return const CheckInResult(success: false, message: 'Duplicate check-in is not allowed.');
    }

    if (checkedInCount() >= event.maxCapacity) {
      return const CheckInResult(success: false, message: 'Capacity is full. Check-in denied.');
    }

    // Important validation flow: only persist entry after all guard checks pass.
    final newCheckin = CheckinModel(
      participantId: participant.id,
      participantName: participant.name,
      checkinTime: DateTime.now(),
    );

    await HiveService.addCheckin(newCheckin);
    _checkins = HiveService.getCheckins();
    notifyListeners();

    return CheckInResult(
      success: true,
      message: '${participant.name} (${participant.id}) checked in successfully.',
    );
  }
}
