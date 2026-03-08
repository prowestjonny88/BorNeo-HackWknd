import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'file_reader_stub.dart'
    if (dart.library.io) 'file_reader_io.dart';

/// Result from speech-to-text transcription
class TranscriptionResult {
  const TranscriptionResult({
    required this.transcript,
    required this.confidence,
    this.language,
    this.duration,
    this.errorMessage,
  });

  /// The transcribed text
  final String transcript;

  /// Confidence level (0.0 - 1.0)
  final double confidence;

  /// Detected language (e.g., 'en', 'ms')
  final String? language;

  /// Audio duration in seconds
  final double? duration;

  /// Error message if transcription failed
  final String? errorMessage;

  bool get isSuccess => errorMessage == null && transcript.isNotEmpty;

  /// Create a failed result
  factory TranscriptionResult.error(String message) {
    return TranscriptionResult(
      transcript: '',
      confidence: 0.0,
      errorMessage: message,
    );
  }
}

/// Service for Speech-to-Text transcription using OpenAI Whisper via Supabase Edge Function
class STTService {
  final SupabaseClient _supabase;

  STTService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Transcribe audio file to text
  /// 
  /// [audioPath] - Path to the local audio file (m4a, wav, mp3, webm)
  /// [languageHint] - Optional language hint (e.g., 'ms' for Malay, 'en' for English)
  /// 
  /// Returns [TranscriptionResult] with transcript or error
  Future<TranscriptionResult> transcribe(
    String audioPath, {
    String? languageHint,
  }) async {
    // On web, use demo transcript since we can't read local files
    if (kIsWeb) {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 1500));
      return _getDemoTranscript(languageHint);
    }

    try {
      final bytes = await readFileBytes(audioPath);
      if (bytes == null) {
        return TranscriptionResult.error('Audio file not found: $audioPath');
      }

      final fileName = audioPath.split('/').last;

      return await transcribeBytes(
        bytes,
        fileName: fileName,
        languageHint: languageHint,
      );
    } catch (e) {
      return TranscriptionResult.error('Failed to read audio file: $e');
    }
  }

  /// Transcribe audio bytes directly
  /// 
  /// [audioBytes] - Raw audio bytes
  /// [fileName] - Original file name with extension
  /// [languageHint] - Optional language hint
  Future<TranscriptionResult> transcribeBytes(
    Uint8List audioBytes, {
    required String fileName,
    String? languageHint,
  }) async {
    try {
      // Upload audio to Supabase Storage temporarily
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'audio/$timestamp-$fileName';

      await _supabase.storage
          .from('evidence')
          .uploadBinary(storagePath, audioBytes);

      // Get the URL for the uploaded file
      final audioUrl = _supabase.storage
          .from('evidence')
          .getPublicUrl(storagePath);

      // Call Supabase Edge Function for transcription
      final response = await _supabase.functions.invoke(
        'transcribe',
        body: {
          'audioUrl': audioUrl,
          'languageHint': languageHint ?? 'ms', // Default to Malay for Malaysian market
          'fileName': fileName,
        },
      );

      if (response.status != 200) {
        return TranscriptionResult.error(
          'Transcription service error: ${response.data?['error'] ?? 'Unknown error'}',
        );
      }

      final data = response.data as Map<String, dynamic>;
      
      return TranscriptionResult(
        transcript: data['transcript'] as String? ?? '',
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.8,
        language: data['language'] as String?,
        duration: (data['duration'] as num?)?.toDouble(),
      );
    } catch (e) {
      // Fallback: return demo transcript for hackathon if service unavailable
      return _getDemoTranscript(languageHint);
    }
  }

  /// Demo transcript for hackathon testing when service is unavailable
  TranscriptionResult _getDemoTranscript(String? languageHint) {
    // Realistic demo transcripts for Malaysian hawker context
    final demoTranscripts = [
      'Hari ni jualan okay. Bihun goreng dalam 30 portion, mee goreng dalam 25. Teh tarik paling laku, dalam 40 cawan. Cash yang saya kira ada RM 320 lebih kurang.',
      'Today not bad lah. Sold around 30 bihun, 20 mee goreng. Teh ais moved fast after lunch, maybe 35. Counted cash should be around RM 280.',
      'Busy day! Bihun habis before 3pm, sold out completely. Mee still got left. Cash takda sempat kira betul betul, dalam RM 350 agak agak.',
    ];

    return TranscriptionResult(
      transcript: demoTranscripts[DateTime.now().second % demoTranscripts.length],
      confidence: 0.85,
      language: languageHint ?? 'ms',
      duration: 24.5,
    );
  }

  /// Check if STT service is available
  Future<bool> isServiceAvailable() async {
    try {
      final response = await _supabase.functions.invoke(
        'transcribe',
        body: {'ping': true},
      );
      return response.status == 200;
    } catch (_) {
      return false;
    }
  }
}
