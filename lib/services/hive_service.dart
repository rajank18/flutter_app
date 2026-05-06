import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';
import '../models/checkin_model.dart';
import '../models/registration_model.dart';
import '../utils/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ParticipantModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CheckinModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RegistrationModelAdapter());
    }

    await Hive.openBox<EventModel>(AppConstants.eventBox);
    await Hive.openBox<ParticipantModel>(AppConstants.participantBox);
    await Hive.openBox<CheckinModel>(AppConstants.checkinBox);
    await Hive.openBox<RegistrationModel>(AppConstants.registrationBox);

    await seedDummyParticipantsIfNeeded();
  }

  static Box<EventModel> get eventBox => Hive.box<EventModel>(AppConstants.eventBox);
  static Box<ParticipantModel> get participantBox => Hive.box<ParticipantModel>(AppConstants.participantBox);
  static Box<CheckinModel> get checkinBox => Hive.box<CheckinModel>(AppConstants.checkinBox);
  static Box<RegistrationModel> get registrationBox => Hive.box<RegistrationModel>(AppConstants.registrationBox);

  static Future<void> saveEvent(EventModel event) async {
    await eventBox.put(event.id, event);
  }

  static EventModel? getCurrentEvent() {
    if (eventBox.isEmpty) return null;
    return eventBox.values.last;
  }

  static List<ParticipantModel> getParticipants() {
    return participantBox.values.toList(growable: false);
  }

  static List<EventModel> getEvents() {
    final events = eventBox.values.toList(growable: false);
    events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return events;
  }

  static List<EventModel> getPublishedEvents() {
    return getEvents().where((event) => event.isPublished ?? true).toList(growable: false);
  }

  static Future<void> updateEvent(EventModel event) async {
    await eventBox.put(event.id, event);
  }

  static Future<void> addRegistration(RegistrationModel registration) async {
    await registrationBox.put(registration.id, registration);
  }

  static List<RegistrationModel> getRegistrations() {
    final registrations = registrationBox.values.toList(growable: false);
    registrations.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return registrations;
  }

  static List<CheckinModel> getCheckins() {
    final list = checkinBox.values.toList(growable: false);
    list.sort((a, b) => b.checkinTime.compareTo(a.checkinTime));
    return list;
  }

  static Future<void> addCheckin(CheckinModel checkin) async {
    await checkinBox.add(checkin);
  }

  static Future<void> seedDummyParticipantsIfNeeded() async {
    if (participantBox.isNotEmpty) return;

    for (final item in AppConstants.dummyParticipants) {
      await participantBox.add(
        ParticipantModel(
          id: item['id']!,
          name: item['name']!,
          qrCode: item['qrCode']!,
        ),
      );
    }
  }
}
