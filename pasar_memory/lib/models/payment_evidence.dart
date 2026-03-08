import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_evidence.freezed.dart';
part 'payment_evidence.g.dart';

@freezed
class PaymentEvidence with _$PaymentEvidence {
  const factory PaymentEvidence({
    required String id,
    required String imagePath,
    required DateTime importedAt,
  }) = _PaymentEvidence;

  factory PaymentEvidence.fromJson(Map<String, dynamic> json) => _$PaymentEvidenceFromJson(json);
}