import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/hive_service.dart';
import '../services/validation_service.dart';

class EventProvider extends ChangeNotifier {
	EventModel? _event;
	bool _loaded = false;

	EventModel? get event => _event;
	bool get hasEvent => _event != null;
	bool get isLoaded => _loaded;

	Future<void> initialize() async {
		_event = HiveService.getCurrentEvent();
		_loaded = true;
		notifyListeners();
	}

	Future<String?> createEvent({
		required String eventName,
		required DateTime? date,
		required TimeOfDay? time,
		required String capacityText,
	}) async {
		final validation = ValidationService.validateEventSetup(
			eventName: eventName,
			date: date,
			time: time,
			capacityText: capacityText,
		);
		if (validation != null) return validation;

		final capacity = int.parse(capacityText.trim());
		final eventDateTime = ValidationService.mergeDateTime(date!, time!);

		final event = EventModel(
			id: const Uuid().v4(),
			eventName: eventName.trim(),
			eventDate: eventDateTime,
			maxCapacity: capacity,
		);

		await HiveService.saveEvent(event);
		_event = event;
		notifyListeners();
		return null;
	}
}

