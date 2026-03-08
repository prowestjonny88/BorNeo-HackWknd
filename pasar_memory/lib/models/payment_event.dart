import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_event.freezed.dart';
part 'payment_event.g.dart';

@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent({
    required String id,
    required String evidenceId,
    required double amount,
    required DateTime timestamp,
    required String providerName,
    required String referenceNumber,
    required String rawText,
    required double extractionConfidence,
    @Default('unmatched') String status,
  }) = _PaymentEvent;

  factory PaymentEvent.fromJson(Map<String, dynamic> json) => _$PaymentEventFromJson(json);
}