import 'package:freezed_annotation/freezed_annotation.dart';

part 'correction_record.freezed.dart';
part 'correction_record.g.dart';

@freezed
class CorrectionRecord with _$CorrectionRecord {
  const factory CorrectionRecord({
    required String id,
    required String matchRecordId,
    required String oldOrderEventId,
    required String newOrderEventId,
    required String reason,
    required DateTime correctedAt,
  }) = _CorrectionRecord;

  factory CorrectionRecord.fromJson(Map<String, dynamic> json) => _$CorrectionRecordFromJson(json);
}