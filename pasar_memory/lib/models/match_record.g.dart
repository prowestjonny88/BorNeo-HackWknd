// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchRecord _$MatchRecordFromJson(Map<String, dynamic> json) => _MatchRecord(
  id: json['id'] as String,
  paymentEventId: json['paymentEventId'] as String,
  orderEventId: json['orderEventId'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  reasons: (json['reasons'] as List<dynamic>).map((e) => e as String).toList(),
  matchedAt: DateTime.parse(json['matchedAt'] as String),
  isManualCorrection: json['isManualCorrection'] as bool? ?? false,
);

Map<String, dynamic> _$MatchRecordToJson(_MatchRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentEventId': instance.paymentEventId,
      'orderEventId': instance.orderEventId,
      'confidenceScore': instance.confidenceScore,
      'reasons': instance.reasons,
      'matchedAt': instance.matchedAt.toIso8601String(),
      'isManualCorrection': instance.isManualCorrection,
    };
