import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'voice_provider.dart';
import '../cash_entry/cash_entry_provider.dart';
import '../review/recap_draft_provider.dart';
import '../review/recap_review_provider.dart';
import '../selling/selling_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/widgets/voice_waveform.dart';

class VoiceRecapScreen extends ConsumerStatefulWidget {
  const VoiceRecapScreen({super.key});

  @override
  ConsumerState<VoiceRecapScreen> createState() => _VoiceRecapScreenState();
}

class _VoiceRecapScreenState extends ConsumerState<VoiceRecapScreen> {
  late final TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);
    final voiceController = ref.read(voiceProvider.notifier);
    final recapController = ref.read(recapDraftProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final displayText = voiceState.transcript ?? '';
    if (displayText != _transcriptController.text && !voiceState.isRecording) {
      _transcriptController.text = displayText;
    }

    ref.listen<VoiceState>(voiceProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppTheme.coral,
            ),
          );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.deepForest, AppTheme.forestGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.softWhite),
                        ),
                        Expanded(
                          child: Text(
                            'Voice Recap',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const ProgressStepper(currentStep: 2),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: voiceState.isRecording
                                  ? AppTheme.coral.withValues(alpha: 0.2)
                                  : AppTheme.amber.withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: voiceState.isRecording
                                      ? AppTheme.coral.withValues(alpha: 0.5)
                                      : AppTheme.amber.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Icon(
                              voiceState.isRecording ? Icons.mic : Icons.mic_none_rounded,
                              color: voiceState.isRecording ? AppTheme.coral : AppTheme.amber,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 28),
                          VoiceWaveform(isRecording: voiceState.isRecording),
                          const SizedBox(height: 28),
                          Text(
                            _formatDuration(voiceState.recordingDuration),
                            style: AppTheme.mono(size: 32, color: AppTheme.amber),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStatusText(voiceState),
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.softWhite.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 26),
                          GestureDetector(
                            onTap: voiceState.isProcessing
                                ? null
                                : () => _handleMainButtonTap(voiceState, voiceController),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _getMainButtonColor(voiceState),
                                shape: BoxShape.circle,
                              ),
                              child: voiceState.isProcessing
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Icon(
                                      _getMainButtonIcon(voiceState),
                                      color: Colors.white,
                                      size: 34,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECAP PROMPTS TO GUIDE YOU',
                              style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _PromptChip(label: 'Items sold?'),
                                _PromptChip(label: 'Any sold out?'),
                                _PromptChip(label: 'Cash counted?'),
                                _PromptChip(label: 'How many bihun?'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'MANUAL TEXT INPUT',
                                  style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: voiceState.isProcessing
                                      ? null
                                      : () async {
                                          final text = _transcriptController.text.trim();
                                          if (text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                const SnackBar(content: Text('Please type your recap first.')),
                                              );
                                            return;
                                          }
                                          voiceController.setTranscript(text);
                                          await voiceController.reparseTranscript();
                                        },
                                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                                  label: const Text('Parse Text'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _transcriptController,
                              minLines: 4,
                              maxLines: 7,
                              onChanged: voiceController.setTranscript,
                              enabled: !voiceState.isProcessing,
                              decoration: const InputDecoration(
                                hintText: 'Example: Today bihun 30, mee 10, cash 320, most payment QR.',
                              ),
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tip: You can skip microphone and type recap directly, then tap Parse Text.',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppTheme.softWhite.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Unknown items warning — shown when Gemini detects items not in menu
                    if (voiceState.unknownItemNames.isNotEmpty)
                      Card(
                        color: AppTheme.coral.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: AppTheme.coral.withValues(alpha: 0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppTheme.coral, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Items Not In Your Menu',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppTheme.coral,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Your recap mentioned item(s) that are not in your menu:',
                                style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: voiceState.unknownItemNames
                                    .map((name) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.coral.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '"$name"',
                                            style: textTheme.bodySmall?.copyWith(
                                              color: AppTheme.coral,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Please redo your recap using only items from your menu.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppTheme.softWhite.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    voiceController.reset();
                                    _transcriptController.clear();
                                  },
                                  icon: const Icon(Icons.mic_rounded, size: 18),
                                  label: const Text('Try Again'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.coral,
                                    side: const BorderSide(color: AppTheme.coral),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (voiceState.isRecording &&
                        voiceState.partialTranscript != null &&
                        voiceState.partialTranscript!.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.hearing_rounded, color: AppTheme.coral, size: 16),
                                  const SizedBox(width: 6),
                                  Text('Listening...', style: textTheme.labelMedium?.copyWith(color: AppTheme.coral)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                voiceState.partialTranscript!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.softWhite.withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!voiceState.isRecording &&
                        (voiceState.transcript?.isNotEmpty == true || voiceState.isProcessing))
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    voiceState.correctedTranscript != null
                                        ? 'TRANSCRIPT (AI CORRECTED)'
                                        : 'TRANSCRIPT',
                                    style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                                  ),
                                  const Spacer(),
                                  if (voiceState.transcript?.isNotEmpty == true)
                                    TextButton.icon(
                                      onPressed: voiceController.reparseTranscript,
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: const Text('Re-parse'),
                                    ),
                                ],
                              ),
                              if (voiceState.correctedTranscript != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.auto_fix_high_rounded, size: 14, color: AppTheme.jade),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Corrected by Gemini AI',
                                      style: textTheme.bodySmall?.copyWith(color: AppTheme.jade),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.softWhite.withValues(alpha: 0.18)),
                                ),
                                child: SelectableText(
                                  (voiceState.transcript ?? '').isEmpty
                                      ? (voiceState.isProcessing
                                          ? 'Correcting & analyzing with Gemini AI...'
                                          : 'Your transcript will appear here after recording or manual input')
                                      : (voiceState.transcript ?? ''),
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (voiceState.parsedRecap?.cashMention != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.jade.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.payments_outlined, color: AppTheme.jade, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Detected cash: RM ${voiceState.parsedRecap!.cashMention!.amount.toStringAsFixed(2)}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.jade,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (voiceState.parsedRecap!.cashMention!.isApproximate)
                                        Text(
                                          ' (approximate)',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppTheme.jade.withValues(alpha: 0.7),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (voiceState.parsedRecap != null && voiceState.parsedRecap!.items.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${voiceState.parsedRecap!.items.length} menu item(s) detected',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppTheme.amber,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (voiceState.transcript?.isNotEmpty == true)
                      OutlinedButton(
                        onPressed: () {
                          voiceController.reset();
                          _transcriptController.clear();
                          ref.read(sellingProvider.notifier).resetAll();
                          ref.read(recapDraftProvider.notifier).resetTranscript();
                          ref.read(cashEntryProvider.notifier).reset();
                          ref.read(recapReviewProvider.notifier).reset();
                        },
                        child: const Text('Start Over'),
                      ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
              if (voiceState.isDone || voiceState.transcript?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: FilledButton(
                    onPressed: () async {
                      if (voiceState.parsedRecap?.cashMention != null) {
                        ref.read(spokenCashAmountProvider.notifier).set(
                              voiceState.parsedRecap!.cashMention!.amount,
                            );
                      } else if (voiceState.parsedRecap != null &&
                          voiceState.parsedRecap!.items.isNotEmpty) {
                        final menuItems = ref.read(sellingProvider).menuItems;
                        final prices = {for (final m in menuItems) m.id: m.price};
                        final estimated = voiceState.parsedRecap!.estimatedTotal(prices);
                        if (estimated > 0) {
                          ref.read(spokenCashAmountProvider.notifier).set(estimated);
                        }
                      }

                      if (voiceState.transcript != null) {
                        recapController.setTranscript(voiceState.transcript!);
                        recapController.confirmTranscript();
                      }

                      if (context.mounted) {
                        context.go('/review');
                      }
                    },
                    child: const Text('Review Recap ->'),
                  ),
                ),
              const AppBottomNav(currentRoute: '/voice-recap'),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(VoiceState state) {
    switch (state.recordingState) {
      case VoiceRecordingState.idle:
        return 'Tap to start recording';
      case VoiceRecordingState.recording:
        return 'Listening... tap to stop & process';
      case VoiceRecordingState.recorded:
        return 'Tap to process';
      case VoiceRecordingState.transcribing:
        return 'Transcribing your voice...';
      case VoiceRecordingState.parsing:
        return 'Correcting & parsing with Gemini AI...';
      case VoiceRecordingState.done:
        return 'Recap ready for review!';
      case VoiceRecordingState.error:
        return 'Something went wrong';
    }
  }

  Color _getMainButtonColor(VoiceState state) {
    switch (state.recordingState) {
      case VoiceRecordingState.recording:
        return AppTheme.coral;
      case VoiceRecordingState.done:
        return AppTheme.jade;
      case VoiceRecordingState.error:
        return AppTheme.coral.withValues(alpha: 0.5);
      default:
        return AppTheme.amber;
    }
  }

  IconData _getMainButtonIcon(VoiceState state) {
    switch (state.recordingState) {
      case VoiceRecordingState.idle:
        return Icons.mic_rounded;
      case VoiceRecordingState.recording:
        return Icons.stop_rounded;
      case VoiceRecordingState.recorded:
        return Icons.play_arrow_rounded;
      case VoiceRecordingState.done:
        return Icons.check_rounded;
      case VoiceRecordingState.error:
        return Icons.refresh_rounded;
      default:
        return Icons.mic_rounded;
    }
  }

  void _handleMainButtonTap(VoiceState state, VoiceController controller) {
    switch (state.recordingState) {
      case VoiceRecordingState.idle:
        controller.startRecording();
        break;
      case VoiceRecordingState.recording:
        controller.stopAndProcess();
        break;
      case VoiceRecordingState.recorded:
        controller.processRecording();
        break;
      case VoiceRecordingState.error:
        controller.reset();
        break;
      case VoiceRecordingState.done:
        break;
      case VoiceRecordingState.transcribing:
      case VoiceRecordingState.parsing:
        break;
    }
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.forestGradientBottom.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
