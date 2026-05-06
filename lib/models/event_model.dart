import 'package:hive/hive.dart';
part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String eventName;
  @HiveField(2)
  DateTime eventDate;
  @HiveField(3)
  int maxCapacity;
  @HiveField(4)
  bool? isPublished;
  @HiveField(5)
  String? createdBy;

  /// If true, normal users must enter the 6-digit [registrationKey] to register.
  /// If false, [registrationKey] should be null.
  @HiveField(6)
  bool requiresSecureKey;

  /// 6-digit registration key stored as a zero-padded string.
  @HiveField(7)
  String? registrationKey;

  EventModel({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.maxCapacity,
    this.isPublished = true,
    this.createdBy,
    this.requiresSecureKey = false,
    this.registrationKey,
  });
}
