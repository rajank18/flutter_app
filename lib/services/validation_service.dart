import 'package:flutter/material.dart';

class ValidationService {
	static String? validateEventSetup({
		required String eventName,
		required DateTime? date,
		required TimeOfDay? time,
		required String capacityText,
	}) {
		if (eventName.trim().isEmpty) return 'Event name is required.';
		if (date == null) return 'Please select event date.';
		if (time == null) return 'Please select event time.';

		final capacity = int.tryParse(capacityText.trim());
		if (capacity == null || capacity <= 0) {
			return 'Maximum capacity must be greater than 0.';
		}
		return null;
	}

	static DateTime mergeDateTime(DateTime date, TimeOfDay time) {
		return DateTime(date.year, date.month, date.day, time.hour, time.minute);
	}

	static String normalizeParticipantId(String rawId) {
		return rawId.trim().toUpperCase();
	}

	static String? validateParticipantId(String rawId) {
		final id = normalizeParticipantId(rawId);
		if (id.isEmpty) return 'Participant ID is required.';
		return null;
	}
}

