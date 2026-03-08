import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'order_event.freezed.dart';
part 'order_event.g.dart';

@freezed
class OrderEvent with _$OrderEvent {
  const factory OrderEvent({
    required String id,
    required List<MenuItem> items,
    required double totalAmount,
    required DateTime timestamp,
    @Default('pending') String status,
  }) = _OrderEvent;

  factory OrderEvent.fromJson(Map<String, dynamic> json) => _$OrderEventFromJson(json);
}