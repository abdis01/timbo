// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 4;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      email: fields[2] as String?,
      isPremium: fields[3] as bool,
      joinedAt: fields[4] as DateTime?,
      aiInteractionsToday: fields[5] as int,
      lastInteractionReset: fields[6] as DateTime?,
      darkModeEnabled: fields[7] as bool,
      cloudSyncEnabled: fields[8] as bool,
      shakeToCapture: fields[9] as bool,
      preferredCaptureType: fields[10] as String?,
      totalNotes: fields[11] as int,
      totalExpenses: fields[12] as int,
      totalReminders: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.isPremium)
      ..writeByte(4)
      ..write(obj.joinedAt)
      ..writeByte(5)
      ..write(obj.aiInteractionsToday)
      ..writeByte(6)
      ..write(obj.lastInteractionReset)
      ..writeByte(7)
      ..write(obj.darkModeEnabled)
      ..writeByte(8)
      ..write(obj.cloudSyncEnabled)
      ..writeByte(9)
      ..write(obj.shakeToCapture)
      ..writeByte(10)
      ..write(obj.preferredCaptureType)
      ..writeByte(11)
      ..write(obj.totalNotes)
      ..writeByte(12)
      ..write(obj.totalExpenses)
      ..writeByte(13)
      ..write(obj.totalReminders);
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
