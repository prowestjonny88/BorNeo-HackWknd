// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_evidence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentEvidence _$PaymentEvidenceFromJson(Map<String, dynamic> json) =>
    _PaymentEvidence(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      importedAt: DateTime.parse(json['importedAt'] as String),
    );

Map<String, dynamic> _$PaymentEvidenceToJson(_PaymentEvidence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'importedAt': instance.importedAt.toIso8601String(),
    };
