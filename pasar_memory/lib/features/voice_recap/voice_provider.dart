import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/repositories/repository_providers.dart';
import '../../models/menu_item.dart';
import '../../services/recap_parser/gemini_recap_service.dart';
import '../../services/recap_parser/menu_aware_parser.dart';
import '../auth/session_provider.dart';
import '../selling/selling_provider.dart';

/// Voice recording states
enum VoiceRecordingState {
  /// Initial state, ready to record
  idle,
  /// Currently recording audio
  recording,
  /// Recording finished, audio available for playback
  recorded,
  /// Transcribing audio to text
  transcribing,
  /// Parsing transcript against menu
  parsing,
  /// Processing complete, ready for review
  done,
  /// Error state
  error,
}

/// State for voice recording and transcription
class VoiceState {
  const VoiceState({
    this.recordingState = VoiceRecordingState.idle,
    this.audioPath,
    this.recordingDuration = Duration.zero,
    this.transcript,
    this.partialTranscript,
    this.parsedRecap,
    this.errorMessage,
    this.amplitude = 0.0,
    this.unknownItemNames = const [],
    this.correctedTranscript,
  });

  /// Current recording state
  final VoiceRecordingState recordingState;

  /// Path to recorded audio file (unused with speech_to_text, kept for API compat)
  final String? audioPath;

  /// Current recording duration
  final Duration recordingDuration;

  /// Final transcribed text from STT
  final String? transcript;

  /// Live partial transcript while still speaking
  final String? partialTranscript;

  /// Parsed recap from transcript
  final ParsedRecap? parsedRecap;

  /// Error message if any
  final String? errorMessage;

  /// Current audio amplitude (for waveform visualization)
  final double amplitude;

  /// Food names from the transcript that did not match any menu item
  final List<String> unknownItemNames;

  /// Gemini-corrected transcript (fixes mishears from STT)
  final String? correctedTranscript;

  bool get isRecording => recordingState == VoiceRecordingState.recording;
  bool get hasRecording => transcript != null && transcript!.isNotEmpty;
  bool get isProcessing =>
      recordingState == VoiceRecordingState.transcribing ||
      recordingState == VoiceRecordingState.parsing;
  bool get isDone => recordingState == VoiceRecordingState.done;
  bool get hasError => recordingState == VoiceRecordingState.error;

  /// The best available transcript text to display
  String get displayTranscript => transcript ?? partialTranscript ?? '';

  VoiceState copyWith({
    VoiceRecordingState? recordingState,
    String? audioPath,
    bool clearAudioPath = false,
    Duration? recordingDuration,
    String? transcript,
    bool clearTranscript = false,
    String? partialTranscript,
    bool clearPartialTranscript = false,
    ParsedRecap? parsedRecap,
    bool clearParsedRecap = false,
    String? errorMessage,
    bool clearError = false,
    double? amplitude,
    List<String>? unknownItemNames,
    bool clearUnknownItems = false,
    String? correctedTranscript,
    bool clearCorrectedTranscript = false,
  }) {
    return VoiceState(
      recordingState: recordingState ?? this.recordingState,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      recordingDuration: recordingDuration ?? this.recordingDuration,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      partialTranscript: clearPartialTranscript ? null : (partialTranscript ?? this.partialTranscript),
      parsedRecap: clearParsedRecap ? null : (parsedRecap ?? this.parsedRecap),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      amplitude: amplitude ?? this.amplitude,
      unknownItemNames: clearUnknownItems ? const [] : (unknownItemNames ?? this.unknownItemNames),
      correctedTranscript: clearCorrectedTranscript ? null : (correctedTranscript ?? this.correctedTranscript),
    );
  }
}

/// Controller for voice recording and transcription
class VoiceController extends Notifier<VoiceState> {
  final SpeechToText _speech = SpeechToText();
  Timer? _durationTimer;
  bool _sttInitialized = false;
  String? _preferredLocaleId;

  static const maxRecordingDuration = Duration(seconds: 60);

  @override
  VoiceState build() {
    ref.onDispose(() {
      _stopTimers();
      _speech.stop();
    });
    return const VoiceState();
  }

  /// Initialize speech recognizer
  Future<bool> _ensureSpeech() async {
    if (_sttInitialized) return true;

    _sttInitialized = await _speech.initialize(
      onError: (error) {
        // Ignore no_match errors — user just paused or spoke unclearly
        if (error.errorMsg == 'error_no_match') return;
        state = state.copyWith(
          recordingState: VoiceRecordingState.error,
          errorMessage: 'Speech recognition error: ${error.errorMsg}',
        );
      },
    );

    if (!_sttInitialized) {
      state = state.copyWith(
        recordingState: VoiceRecordingState.error,
        errorMessage: 'Speech recognition not available on this device/browser.',
      );
      return false;
    }

    _preferredLocaleId = await _resolveLocale();
    return _sttInitialized;
  }

  Future<String?> _resolveLocale() async {
    try {
      final locales = await _speech.locales();
      if (locales.isEmpty) return null;

      final hasMalay = locales.any((l) => l.localeId == 'ms_MY');
      if (hasMalay) return 'ms_MY';

      final systemLocale = await _speech.systemLocale();
      if (systemLocale != null && locales.any((l) => l.localeId == systemLocale.localeId)) {
        return systemLocale.localeId;
      }

      return locales.first.localeId;
    } catch (_) {
      return null;
    }
  }

  /// Start recording and recognizing speech
  Future<void> startRecording() async {
    if (state.isRecording) return;
    if (!await _ensureSpeech()) return;

    state = state.copyWith(
      recordingState: VoiceRecordingState.recording,
      recordingDuration: Duration.zero,
      clearTranscript: true,
      clearPartialTranscript: true,
      clearParsedRecap: true,
      clearError: true,
    );

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newDuration = state.recordingDuration + const Duration(seconds: 1);
      if (newDuration >= maxRecordingDuration) {
        stopAndProcess();
        return;
      }
      state = state.copyWith(recordingDuration: newDuration);
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: maxRecordingDuration,
      pauseFor: const Duration(seconds: 4),
      localeId: _preferredLocaleId,
      onSoundLevelChange: (level) {
        // level is -2 to 10; normalize to 0-1
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        state = state.copyWith(amplitude: normalized);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      state = state.copyWith(
        transcript: result.recognizedWords,
        clearPartialTranscript: true,
      );
    } else {
      state = state.copyWith(partialTranscript: result.recognizedWords);
    }
  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    if (!state.isRecording) return;
    _stopTimers();
    await _speech.stop();

    state = state.copyWith(
      recordingState: VoiceRecordingState.recorded,
      amplitude: 0.0,
    );
  }

  /// Stop recording and immediately parse
  Future<void> stopAndProcess() async {
    if (!state.isRecording) return;
    _stopTimers();
    await _speech.stop();

    await _awaitTranscriptFlush();

    // Use whichever transcript we have (final or last partial)
    final transcript = state.transcript ?? state.partialTranscript ?? '';

    if (transcript.trim().isEmpty) {
      state = state.copyWith(
        recordingState: VoiceRecordingState.error,
        errorMessage: 'No speech detected. Please try again.',
        amplitude: 0.0,
      );
      return;
    }

    state = state.copyWith(
      recordingState: VoiceRecordingState.parsing,
      transcript: transcript,
      clearPartialTranscript: true,
      amplitude: 0.0,
    );

    await _parseTranscript(transcript);
  }

  Future<void> _awaitTranscriptFlush() async {
    if ((state.transcript ?? state.partialTranscript ?? '').trim().isNotEmpty) {
      return;
    }

    // Some engines deliver final words slightly after stop().
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if ((state.transcript ?? state.partialTranscript ?? '').trim().isNotEmpty) {
        return;
      }
    }
  }

  /// Transcribe and parse (called after stopRecording)
  Future<void> processRecording() async {
    final transcript = state.transcript ?? state.partialTranscript ?? '';
    if (transcript.trim().isEmpty) {
      state = state.copyWith(
        recordingState: VoiceRecordingState.error,
        errorMessage: 'No transcript to process.',
      );
      return;
    }

    state = state.copyWith(
      recordingState: VoiceRecordingState.parsing,
      transcript: transcript,
      clearPartialTranscript: true,
    );
    await _parseTranscript(transcript);
  }

  /// Parse transcript against menu items — uses Gemini AI, falls back to rule-based parser
  Future<void> _parseTranscript(String transcript) async {
    var menuItems = ref.read(sellingProvider).menuItems;

    // If selling provider hasn't loaded yet, read directly from file cache
    if (menuItems.isEmpty) {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isNotEmpty) {
        final repo = ref.read(menuRepositoryProvider);
        menuItems = await repo.getAllMenuItems(accountId: accountId);
      }
    }

    // --- Try Gemini AI first ---
    try {
      final gemini = GeminiRecapService();
      final result = await gemini.parse(transcript, menuItems);

      // User mentioned items not in the menu — ask them to redo
      if (result.hasUnknownItems) {
        final names = result.unknownItems.join(', ');
        state = state.copyWith(
          recordingState: VoiceRecordingState.error,
          errorMessage:
              'These item(s) are not in your menu: $names. Please redo your voice recap using only items from your menu.',
          unknownItemNames: result.unknownItems,
          transcript: transcript,
          correctedTranscript: result.correctedTranscript,
        );
        return;
      }

      // User said quantity before item name — enforce ordering rule
      if (result.hasOrderingError) {
        final examples = result.orderingErrorItems.join(', ');
        state = state.copyWith(
          recordingState: VoiceRecordingState.error,
          errorMessage:
              'Please say the item name first, then the quantity. Wrong order detected: $examples. '
              'Example: say "mee 10", not "10 mee".',
          unknownItemNames: const [],
          transcript: transcript,
          correctedTranscript: result.correctedTranscript,
        );
        return;
      }

      state = state.copyWith(
        parsedRecap: result.parsedRecap,
        recordingState: VoiceRecordingState.done,
        clearUnknownItems: true,
        correctedTranscript: result.correctedTranscript,
        // Replace raw STT transcript with the corrected version for display
        transcript: result.correctedTranscript ?? transcript,
      );
      _applyParsedItemsToSelling(result.parsedRecap);
      return;
    } catch (_) {
      // Gemini unavailable (no internet, quota, etc.) — fall back to local parser
    }

    // --- Fallback: local rule-based parser ---
    try {
      final parser = MenuAwareParser();
      final parsedRecap = parser.parse(transcript, menuItems);
      state = state.copyWith(
        parsedRecap: parsedRecap,
        recordingState: VoiceRecordingState.done,
        clearUnknownItems: true,
      );
      _applyParsedItemsToSelling(parsedRecap);
    } catch (e) {
      state = state.copyWith(
        recordingState: VoiceRecordingState.error,
        errorMessage: 'Parsing failed: $e',
      );
    }
  }

  /// Apply parsed items to selling provider
  void _applyParsedItemsToSelling(ParsedRecap recap) {
    final sellingController = ref.read(sellingProvider.notifier);

    for (final item in recap.items) {
      final menuItem = ref.read(sellingProvider).menuItems.firstWhere(
            (m) => m.id == item.menuItemId,
            orElse: () => MenuItem(id: '', name: '', price: 0, isActive: false),
          );

      if (menuItem.id.isNotEmpty) {
        sellingController.updateCount(menuItem, item.quantity);
      }
    }
  }

  /// Set transcript manually (for editing)
  void setTranscript(String transcript) {
    state = state.copyWith(
      transcript: transcript,
      clearParsedRecap: true,
    );
  }

  /// Re-parse the transcript (after manual edit)
  Future<void> reparseTranscript() async {
    if (state.transcript == null || state.transcript!.isEmpty) return;
    state = state.copyWith(recordingState: VoiceRecordingState.parsing);
    await _parseTranscript(state.transcript!);
  }

  /// Reset and start fresh
  void reset() {
    _stopTimers();
    _speech.stop();
    state = const VoiceState();
  }

  /// Save the transcript record to database
  Future<bool> saveTranscript() async {
    if (state.transcript == null || state.transcript!.isEmpty) {
      state = state.copyWith(errorMessage: 'No transcript to save');
      return false;
    }

    try {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isEmpty) {
        state = state.copyWith(errorMessage: 'Please log in to save transcript');
        return false;
      }

      final recapRepo = ref.read(recapRepositoryProvider);
      await recapRepo.saveRecap({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'evidenceId': DateTime.now().toIso8601String().split('T').first,
        'rawText': state.transcript,
        'parsedJson': state.parsedRecap?.toJson().toString() ?? '{}',
        'confidence': state.parsedRecap?.overallConfidence.index ?? 0 / 2.0,
      }, accountId: accountId);

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save transcript: $e');
      return false;
    }
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }
}

/// Provider for voice recording state and controls
final voiceProvider = NotifierProvider<VoiceController, VoiceState>(
  VoiceController.new,
);

// Note: Use spokenCashAmountProvider from cash_entry_provider.dart
// to prefill the cash entry with detected cash amounts.
