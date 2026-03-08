// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correction_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CorrectionRecord _$CorrectionRecordFromJson(Map<String, dynamic> json) =>
    _CorrectionRecord(
      id: json['id'] as String,
      matchRecordId: json['matchRecordId'] as String,
      oldOrderEventId: json['oldOrderEventId'] as String,
      newOrderEventId: json['newOrderEventId'] as String,
      reason: json['reason'] as String,
      correctedAt: DateTime.parse(json['correctedAt'] as String),
    );

Map<String, dynamic> _$CorrectionRecordToJson(_CorrectionRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchRecordId': instance.matchRecordId,
      'oldOrderEventId': instance.oldOrderEventId,
      'newOrderEventId': instance.newOrderEventId,
      'reason': instance.reason,
      'correctedAt': instance.correctedAt.toIso8601String(),
    };
