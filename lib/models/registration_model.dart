import 'package:hive/hive.dart';
part 'registration_model.g.dart';

@HiveType(typeId: 3)
class RegistrationModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String eventId;
  @HiveField(2)
  String eventName;
  @HiveField(3)
  String userEmail;
  @HiveField(4)
  DateTime registeredAt;

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.userEmail,
    required this.registeredAt,
  });
}
