import 'package:flutter/material.dart';

class EvidenceSourceChip extends StatelessWidget {
  final String source; // 'Screenshot', 'Voice', 'Export'
  final VoidCallback? onTap;

  const EvidenceSourceChip({super.key, required this.source, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (source.toLowerCase()) {
      case 'voice':
        icon = Icons.mic;
        break;
      case 'screenshot':
        icon = Icons.image;
        break;
      default:
        icon = Icons.Description;
    }

    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(source),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}