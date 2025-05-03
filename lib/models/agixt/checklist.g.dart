// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AGiXTChecklistAdapter extends TypeAdapter<AGiXTChecklist> {
  @override
  final int typeId = 3;

  @override
  AGiXTChecklist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AGiXTChecklist(
      name: fields[1] as String,
      duration: fields[2] as int,
      showUntil: fields[4] as DateTime?,
      uuid: fields[0] as String?,
    )..items = (fields[5] as List).cast<AGiXTCheckListItem>();
  }

  @override
  void write(BinaryWriter writer, AGiXTChecklist obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.showUntil)
      ..writeByte(5)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AGiXTChecklistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AGiXTCheckListItemAdapter extends TypeAdapter<AGiXTCheckListItem> {
  @override
  final int typeId = 4;

  @override
  AGiXTCheckListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AGiXTCheckListItem(
      title: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AGiXTCheckListItem obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AGiXTCheckListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
