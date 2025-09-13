// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CertificateModelAdapter extends TypeAdapter<CertificateModel> {
  @override
  final int typeId = 4;

  @override
  CertificateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CertificateModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      eventId: fields[2] as String,
      certificateUrl: fields[3] as String,
      certificateCode: fields[4] as String,
      templateUsed: fields[5] as String?,
      issuedAt: fields[6] as DateTime,
      downloadedAt: fields[7] as DateTime?,
      eventTitle: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CertificateModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.certificateUrl)
      ..writeByte(4)
      ..write(obj.certificateCode)
      ..writeByte(5)
      ..write(obj.templateUsed)
      ..writeByte(6)
      ..write(obj.issuedAt)
      ..writeByte(7)
      ..write(obj.downloadedAt)
      ..writeByte(8)
      ..write(obj.eventTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
