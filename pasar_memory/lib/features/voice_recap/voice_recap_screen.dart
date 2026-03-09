import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../review/recap_draft_provider.dart';
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
  late final ProviderSubscription<RecapDraftState> _recapSubscription;

  final _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(recapDraftProvider);
    _transcriptController = TextEditingController(text: initialState.transcript);
    _recapSubscription = ref.listenManual<RecapDraftState>(recapDraftProvider, (prev, next) {
      if (next.transcript != _transcriptController.text) {
        _transcriptController.value = _transcriptController.value.copyWith(
          text: next.transcript,
          selection: TextSelection.collapsed(offset: next.transcript.length),
        );
      }

      final prevError = prev?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != prevError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.cancel();
    _recapSubscription.close();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          _timer?.cancel();
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) {
          _timer?.cancel();
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleRecording() async {
    final recapController = ref.read(recapDraftProvider.notifier);
    if (_isListening) {
      await _speech.stop();
      _timer?.cancel();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition unavailable — type your recap below.')),
      );
      return;
    }
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          recapController.setTranscript(result.recognizedWords);
        }
      },
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
    );
    if (!mounted) return;
    setState(() {
      _isListening = _speech.isListening;
      if (_isListening) _elapsed = 0;
    });
    if (_speech.isListening) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) { _timer?.cancel(); return; }
        setState(() {
          _elapsed++;
          if (!_speech.isListening) {
            _isListening = false;
            _timer?.cancel();
          }
        });
      });
    }
  }

  String _formatTime() {
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final recap = ref.watch(recapDraftProvider);
    final recapController = ref.read(recapDraftProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isListening
                                  ? 'Listening… speak naturally'
                                  : recap.isTranscriptConfirmed
                                      ? 'Recap captured ✔'
                                      : 'Tap the mic to start recording',
                              key: ValueKey(_isListening),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: _isListening
                                    ? AppTheme.jade
                                    : AppTheme.softWhite.withValues(alpha: 0.75),
                                fontWeight:
                                    _isListening ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          VoiceWaveform(isRecording: _isListening),
                          const SizedBox(height: 20),
                          Text(
                            _formatTime(),
                            style: AppTheme.mono(
                              size: 34,
                              color: _isListening ? AppTheme.jade : AppTheme.amber,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? AppTheme.coral
                                    : recap.isTranscriptConfirmed
                                        ? AppTheme.jade
                                        : AppTheme.amber,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening ? AppTheme.coral : AppTheme.amber)
                                        .withValues(alpha: _isListening ? 0.55 : 0.35),
                                    blurRadius: _isListening ? 36 : 16,
                                    spreadRadius: _isListening ? 8 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening
                                    ? Icons.stop_rounded
                                    : recap.isTranscriptConfirmed
                                        ? Icons.check_rounded
                                        : Icons.mic_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          if (!_speechAvailable && !_isListening)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Type your recap in the field below',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppTheme.softWhite.withValues(alpha: 0.45),
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
                                _PromptChip(label: 'Cash or QR?'),
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
                            Text(
                              'TRANSCRIPT',
                              style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _transcriptController,
                              minLines: 5,
                              maxLines: 7,
                              onChanged: recapController.setTranscript,
                              decoration: const InputDecoration(
                                hintText: 'Example: Sold 12 bihun, 9 mee goreng, cash around RM 180.',
                              ),
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                    if (recap.cashSuggestion != null)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.jade.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppTheme.jade.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.payments_outlined,
                                        color: AppTheme.jade, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cash detected: RM ${recap.cashSuggestion!.toStringAsFixed(2)}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.jade,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () async {
                        if (_isListening) {
                          await _speech.stop();
                          _timer?.cancel();
                          if (mounted) setState(() => _isListening = false);
                        }
                        final ok = recapController.confirmTranscript();
                        if (!ok) return;
                        if (context.mounted) context.go('/cash');
                      },
                      child: const Text('Confirm Recap →'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        if (_isListening) {
                          await _speech.stop();
                          _timer?.cancel();
                          if (mounted) setState(() { _isListening = false; _elapsed = 0; });
                        }
                        recapController.resetTranscript();
                      },
                      child: const Text('Clear & Re-record'),
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