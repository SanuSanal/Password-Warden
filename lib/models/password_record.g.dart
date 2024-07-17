// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordRecordAdapter extends TypeAdapter<PasswordRecord> {
  @override
  final int typeId = 0;

  @override
  PasswordRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordRecord(
      applicationName: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      additionalInfo: (fields[3] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PasswordRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.applicationName)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.additionalInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
