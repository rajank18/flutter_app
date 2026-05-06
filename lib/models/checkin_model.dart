import 'package:hive/hive.dart';
part 'checkin_model.g.dart';

@HiveType(typeId: 2)
class CheckinModel extends HiveObject {
  @HiveField(0)
  String participantId;
  @HiveField(1)
  String participantName;
  @HiveField(2)
  DateTime checkinTime;

  CheckinModel({
    required this.participantId,
    required this.participantName,
    required this.checkinTime,
  });
}
