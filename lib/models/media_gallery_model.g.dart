// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_gallery_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaGalleryModelAdapter extends TypeAdapter<MediaGalleryModel> {
  @override
  final int typeId = 6;

  @override
  MediaGalleryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaGalleryModel(
      id: fields[0] as String,
      eventId: fields[1] as String,
      fileType: fields[2] as String,
      fileUrl: fields[3] as String,
      uploadedBy: fields[4] as String,
      caption: fields[5] as String?,
      uploadedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MediaGalleryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.fileType)
      ..writeByte(3)
      ..write(obj.fileUrl)
      ..writeByte(4)
      ..write(obj.uploadedBy)
      ..writeByte(5)
      ..write(obj.caption)
      ..writeByte(6)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaGalleryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
