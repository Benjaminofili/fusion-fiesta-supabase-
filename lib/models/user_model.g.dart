// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      phone: fields[4] as String?,
      role: fields[5] as String,
      enrollmentNumber: fields[6] as String?,
      department: fields[7] as String?,
      collegeIdProofUrl: fields[8] as String?,
      profilePictureUrl: fields[9] as String?,
      approved: fields[10] as bool,
      isLocalOnly: fields[11] as bool,
      sessionToken: fields[12] as String?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
      lastModified: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.enrollmentNumber)
      ..writeByte(7)
      ..write(obj.department)
      ..writeByte(8)
      ..write(obj.collegeIdProofUrl)
      ..writeByte(9)
      ..write(obj.profilePictureUrl)
      ..writeByte(10)
      ..write(obj.approved)
      ..writeByte(11)
      ..write(obj.isLocalOnly)
      ..writeByte(12)
      ..write(obj.sessionToken)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
