// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailySummary _$DailySummaryFromJson(Map<String, dynamic> json) =>
    _DailySummary(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      digitalTotal: (json['digitalTotal'] as num).toDouble(),
      cashEstimate: (json['cashEstimate'] as num).toDouble(),
      unresolvedCount: (json['unresolvedCount'] as num).toInt(),
      isConfirmed: json['isConfirmed'] as bool,
    );

Map<String, dynamic> _$DailySummaryToJson(_DailySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'totalSales': instance.totalSales,
      'digitalTotal': instance.digitalTotal,
      'cashEstimate': instance.cashEstimate,
      'unresolvedCount': instance.unresolvedCount,
      'isConfirmed': instance.isConfirmed,
    };
