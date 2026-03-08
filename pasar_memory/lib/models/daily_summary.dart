import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_summary.freezed.dart';
part 'daily_summary.g.dart';

@freezed
class DailySummary with _$DailySummary {
  const factory DailySummary({
    required String id,
    required DateTime date,
    required double totalSales,
    required double digitalTotal,
    required double cashEstimate,
    required int unresolvedCount,
    required bool isConfirmed,
  }) = _DailySummary;

  factory DailySummary.fromJson(Map<String, dynamic> json) => _$DailySummaryFromJson(json);
}