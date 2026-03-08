// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentEvent _$PaymentEventFromJson(Map<String, dynamic> json) =>
    _PaymentEvent(
      id: json['id'] as String,
      evidenceId: json['evidenceId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      providerName: json['providerName'] as String,
      referenceNumber: json['referenceNumber'] as String,
      rawText: json['rawText'] as String,
      extractionConfidence: (json['extractionConfidence'] as num).toDouble(),
      status: json['status'] as String? ?? 'unmatched',
    );

Map<String, dynamic> _$PaymentEventToJson(_PaymentEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'evidenceId': instance.evidenceId,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'providerName': instance.providerName,
      'referenceNumber': instance.referenceNumber,
      'rawText': instance.rawText,
      'extractionConfidence': instance.extractionConfidence,
      'status': instance.status,
    };
