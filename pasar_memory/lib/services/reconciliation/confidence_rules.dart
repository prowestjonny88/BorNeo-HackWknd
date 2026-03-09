enum ReconciliationConfidence {
  high,
  medium,
  low,
  merchantConfirmed,
  needsReview,
}

class ConfidenceRules {
  const ConfidenceRules();

  ReconciliationConfidence forDigitalAmount({
    required double sourceConfidence,
    required bool fromSettlementStyle,
    required bool fromHistoryStyle,
  }) {
    if (sourceConfidence >= 0.85 || fromSettlementStyle) {
      return ReconciliationConfidence.high;
    }
    if (fromHistoryStyle || sourceConfidence >= 0.65) {
      return ReconciliationConfidence.medium;
    }
    return ReconciliationConfidence.needsReview;
  }

  ReconciliationConfidence forCash({
    required bool typedByMerchant,
    required bool fromVoice,
  }) {
    if (typedByMerchant) return ReconciliationConfidence.merchantConfirmed;
    if (fromVoice) return ReconciliationConfidence.medium;
    return ReconciliationConfidence.needsReview;
  }

  ReconciliationConfidence forItemCount({
    required bool fromTap,
    required bool isApproximate,
  }) {
    if (fromTap) return ReconciliationConfidence.high;
    if (isApproximate) return ReconciliationConfidence.low;
    return ReconciliationConfidence.medium;
  }
}
