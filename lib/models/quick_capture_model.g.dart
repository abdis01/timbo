// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_capture_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuickCaptureModelAdapter extends TypeAdapter<QuickCaptureModel> {
  @override
  final int typeId = 3;

  @override
  QuickCaptureModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickCaptureModel(
      id: fields[0] as String?,
      type: fields[1] as String,
      content: fields[2] as String,
      mediaPath: fields[3] as String?,
      amount: fields[4] as double?,
      category: fields[5] as String?,
      capturedAt: fields[6] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      isProcessed: fields[7] as bool,
      suggestedCategory: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuickCaptureModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.mediaPath)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.capturedAt)
      ..writeByte(7)
      ..write(obj.isProcessed)
      ..writeByte(8)
      ..write(obj.suggestedCategory)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickCaptureModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
