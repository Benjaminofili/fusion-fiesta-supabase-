// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 1;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      department: fields[4] as String?,
      dateTime: fields[5] as DateTime,
      venue: fields[6] as String,
      status: fields[7] as String,
      organizerId: fields[8] as String?,
      maxParticipants: fields[9] as int?,
      currentParticipants: fields[10] as int?,
      bannerUrl: fields[11] as String?,
      cost: fields[12] as double?,
      registrationDeadline: fields[13] as DateTime?,
      eventType: fields[14] as String,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      isBookmarked: fields[17] as bool?,
      registrationsCount: fields[18] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.department)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.venue)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.organizerId)
      ..writeByte(9)
      ..write(obj.maxParticipants)
      ..writeByte(10)
      ..write(obj.currentParticipants)
      ..writeByte(11)
      ..write(obj.bannerUrl)
      ..writeByte(12)
      ..write(obj.cost)
      ..writeByte(13)
      ..write(obj.registrationDeadline)
      ..writeByte(14)
      ..write(obj.eventType)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.isBookmarked)
      ..writeByte(18)
      ..write(obj.registrationsCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
