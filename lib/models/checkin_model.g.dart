// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckinModelAdapter extends TypeAdapter<CheckinModel> {
  @override
  final int typeId = 2;

  @override
  CheckinModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckinModel(
      participantId: fields[0] as String,
      participantName: fields[1] as String,
      checkinTime: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CheckinModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.participantId)
      ..writeByte(1)
      ..write(obj.participantName)
      ..writeByte(2)
      ..write(obj.checkinTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckinModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
