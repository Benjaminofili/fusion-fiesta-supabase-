// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackModelAdapter extends TypeAdapter<FeedbackModel> {
  @override
  final int typeId = 3;

  @override
  FeedbackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedbackModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      message: fields[2] as String,
      rating: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FeedbackModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
