import 'package:flutter/material.dart';

enum TrustLevel { confirmed, reliable, estimated, review }

class TrustBadge extends StatelessWidget {
  final TrustLevel level;

  const TrustBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (level) {
      case TrustLevel.confirmed:
        color = Colors.green;
        label = "Merchant Confirmed";
        break;
      case TrustLevel.reliable:
        color = Colors.blue;
        label = "From Source";
        break;
      case TrustLevel.estimated:
        color = Colors.orange;
        label = "Estimated";
        break;
      case TrustLevel.review:
        color = Colors.red;
        label = "Needs Review";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}