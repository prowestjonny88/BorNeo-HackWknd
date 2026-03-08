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

    // Sync transcript controller with finalized voice state
    final displayText = voiceState.transcript ?? '';
    if (displayText != _transcriptController.text && !voiceState.isRecording) {
      _transcriptController.text = displayText;
    }

    // Show error snackbar
    ref.listen<VoiceState>(voiceProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.coral,
          ));
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
                          onPressed: () => Navigator.of(context).maybePop(),
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
                          VoiceWaveform(
                            isRecording: voiceState.isRecording,
                          ),
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
                          // Main recording/action button
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
                    // Live partial transcript shown while recording
                    if (voiceState.isRecording && voiceState.partialTranscript != null && voiceState.partialTranscript!.isNotEmpty)
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
                    // Transcript section - shows after recording done
                    if (!voiceState.isRecording && (voiceState.transcript?.isNotEmpty == true || voiceState.isProcessing))
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'TRANSCRIPT',
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
                              const SizedBox(height: 10),
                              TextField(
                                controller: _transcriptController,
                                minLines: 4,
                                maxLines: 7,
                                onChanged: voiceController.setTranscript,
                                decoration: InputDecoration(
                                  hintText: voiceState.isProcessing
                                    ? 'Analyzing your recap...'
                                    : 'Your transcript will appear here after recording',
                                ),
                                style: textTheme.bodyLarge,
                                enabled: !voiceState.isProcessing,
                              ),
                              const SizedBox(height: 8),
                              // Show parsed cash if detected
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
                              // Show parsed items count
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
                    const SizedBox(height: 20),
                                    // Continue button
                    if (voiceState.isDone || voiceState.transcript?.isNotEmpty == true)
                      FilledButton(
                        onPressed: () async {
                          if (voiceState.parsedRecap?.cashMention != null) {
                            ref.read(spokenCashAmountProvider.notifier).set(
                              voiceState.parsedRecap!.cashMention!.amount,
                            );
                          } else if (voiceState.parsedRecap != null &&
                              voiceState.parsedRecap!.items.isNotEmpty) {
                            // Auto-estimate cash from items × price when no cash keyword spoken
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
                          context.go('/review');
                        },
                        child: const Text('Review Recap ->'),
                      ),
                    const SizedBox(height: 12),
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
        return 'Analyzing your recap...';
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
        // Stop and immediately parse in one tap
        controller.stopAndProcess();
        break;
      case VoiceRecordingState.recorded:
        controller.processRecording();
        break;
      case VoiceRecordingState.error:
        controller.reset();
        break;
      case VoiceRecordingState.done:
        // Already done, button should navigate
        break;
      default:
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