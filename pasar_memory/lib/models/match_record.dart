import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_record.freezed.dart';
part 'match_record.g.dart';

@freezed
class MatchRecord with _$MatchRecord {
  const factory MatchRecord({
    required String id,
    required String paymentEventId,
    required String orderEventId,
    required double confidenceScore,
    required List<String> reasons,
    required DateTime matchedAt,
    @Default(false) bool isManualCorrection,
  }) = _MatchRecord;

  factory MatchRecord.fromJson(Map<String, dynamic> json) => _$MatchRecordFromJson(json);
}