import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';
import '../models/checkin_model.dart';
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

    await Hive.openBox<EventModel>(AppConstants.eventBox);
    await Hive.openBox<ParticipantModel>(AppConstants.participantBox);
    await Hive.openBox<CheckinModel>(AppConstants.checkinBox);

    await seedDummyParticipantsIfNeeded();
  }

  static Box<EventModel> get eventBox => Hive.box<EventModel>(AppConstants.eventBox);
  static Box<ParticipantModel> get participantBox => Hive.box<ParticipantModel>(AppConstants.participantBox);
  static Box<CheckinModel> get checkinBox => Hive.box<CheckinModel>(AppConstants.checkinBox);

  static Future<void> saveEvent(EventModel event) async {
    await eventBox.clear();
    await eventBox.add(event);
    await checkinBox.clear();
  }

  static EventModel? getCurrentEvent() {
    if (eventBox.isEmpty) return null;
    return eventBox.getAt(0);
  }

  static List<ParticipantModel> getParticipants() {
    return participantBox.values.toList(growable: false);
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
