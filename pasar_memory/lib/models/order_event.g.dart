// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderEvent _$OrderEventFromJson(Map<String, dynamic> json) => _OrderEvent(
  id: json['id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  status: json['status'] as String? ?? 'pending',
);

Map<String, dynamic> _$OrderEventToJson(_OrderEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
    };
