// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Merchant _$MerchantFromJson(Map<String, dynamic> json) => _Merchant(
  id: json['id'] as String,
  name: json['name'] as String,
  businessType: json['businessType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MerchantToJson(_Merchant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'businessType': instance.businessType,
  'createdAt': instance.createdAt.toIso8601String(),
};
