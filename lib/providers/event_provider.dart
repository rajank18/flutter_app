import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/hive_service.dart';
import '../services/validation_service.dart';

class EventProvider extends ChangeNotifier {
	List<EventModel> _events = [];
	bool _loaded = false;

	List<EventModel> get events => _events;
	EventModel? get event => _events.isEmpty ? null : _events.first;
	EventModel? get latestEvent => _events.isEmpty ? null : _events.first;
	List<EventModel> get publishedEvents => _events.where((event) => event.isPublished ?? true).toList(growable: false);
	List<EventModel> eventsByCreator(String email) =>
	    _events.where((event) => event.createdBy == email).toList(growable: false);
	bool get hasEvent => _events.isNotEmpty;
	bool get isLoaded => _loaded;

	Future<void> initialize() async {
		_events = HiveService.getEvents();
		_loaded = true;
		notifyListeners();
	}

	Future<String?> createEvent({
		required String eventName,
		required DateTime? date,
		required TimeOfDay? time,
		required String capacityText,
		bool isPublished = true,
		String? createdBy,
		bool requiresSecureKey = false,
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

		String? key;
		if (requiresSecureKey) {
			// Generate a 6-digit key (as a zero-padded string).
			final raw = DateTime.now().millisecondsSinceEpoch % 1000000;
			key = raw.toString().padLeft(6, '0');
		}

		final event = EventModel(
			id: const Uuid().v4(),
			eventName: eventName.trim(),
			eventDate: eventDateTime,
			maxCapacity: capacity,
			isPublished: isPublished,
			createdBy: createdBy,
			requiresSecureKey: requiresSecureKey,
			registrationKey: key,
		);

		await HiveService.saveEvent(event);
		_events = HiveService.getEvents();
		notifyListeners();
		return null;
	}

Future<void> togglePublish(EventModel event, bool value) async {
		final updated = EventModel(
			id: event.id,
			eventName: event.eventName,
			eventDate: event.eventDate,
			maxCapacity: event.maxCapacity,
			isPublished: value,
			createdBy: event.createdBy,
			requiresSecureKey: event.requiresSecureKey,
			registrationKey: event.registrationKey,
		);
		await HiveService.updateEvent(updated);
		_events = HiveService.getEvents();
		notifyListeners();
	}
}

