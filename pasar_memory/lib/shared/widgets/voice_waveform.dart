import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VoiceWaveform extends StatefulWidget {
  const VoiceWaveform({
    super.key,
    this.isRecording = true,
  });

  final bool isRecording;

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const _baseHeights = [
    10.0, 14.0, 18.0, 24.0, 30.0, 36.0, 28.0, 20.0, 14.0, 10.0, 16.0, 22.0,
    22.0, 16.0, 10.0, 14.0, 20.0, 28.0, 36.0, 30.0, 24.0, 18.0, 14.0, 10.0,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isRecording) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording == oldWidget.isRecording) return;
    if (widget.isRecording) {
      _ctrl.repeat();
    } else {
      _ctrl.animateTo(0, duration: const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_baseHeights.length, (i) {
            final phase = (i / _baseHeights.length) * 2 * pi;
            final wave = widget.isRecording
                ? (0.45 + 0.55 * sin(_ctrl.value * 2 * pi + phase))
                : 0.2;
            final h = (_baseHeights[i] * wave).clamp(4.0, 40.0);
            final color = Color.lerp(
              AppTheme.amber,
              AppTheme.jade,
              i / (_baseHeights.length - 1),
            )!;
            return Container(
              width: 4,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: widget.isRecording ? 1.0 : 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        );
      },
    );
  }
}