import 'package:hive/hive.dart';
part 'participant_model.g.dart';

@HiveType(typeId: 1)
class ParticipantModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String qrCode;

  ParticipantModel({
    required this.id,
    required this.name,
    required this.qrCode,
  });
}
