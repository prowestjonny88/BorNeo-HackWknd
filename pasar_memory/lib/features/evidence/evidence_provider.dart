import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';

enum EvidenceSource {
  screenshot,
  export,
  shared,
}

enum EvidenceProcessingStatus {
  idle,
  processing,
  done,
  error,
}

class EvidenceIngestedFile {
  final String id;
  final String name;
  final String? path;
  final Uint8List? bytes;
  final EvidenceSource source;
  final DateTime addedAt;
  final int dedupeHash;

  const EvidenceIngestedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.bytes,
    required this.source,
    required this.addedAt,
    required this.dedupeHash,
  });
}

class ExtractedAmount {
  final String id;
  final double amount;
  final String trustLabel;

  const ExtractedAmount({
    required this.id,
    required this.amount,
    required this.trustLabel,
  });

}

class EvidenceFileResult {
  final List<ExtractedAmount> amounts;
  final String? errorMessage;

  const EvidenceFileResult({
    this.amounts = const <ExtractedAmount>[],
    this.errorMessage,
  });
}

class EvidenceState {
  final List<EvidenceIngestedFile> files;
  final Map<String, EvidenceProcessingStatus> statusById;
  final Map<String, EvidenceFileResult> resultById;
  final List<EvidenceIngestedFile> pendingDuplicateAdds;
  final String? warningMessage;

  const EvidenceState({
    this.files = const <EvidenceIngestedFile>[],
    this.statusById = const <String, EvidenceProcessingStatus>{},
    this.resultById = const <String, EvidenceFileResult>{},
    this.pendingDuplicateAdds = const <EvidenceIngestedFile>[],
    this.warningMessage,
  });

  EvidenceState copyWith({
    List<EvidenceIngestedFile>? files,
    Map<String, EvidenceProcessingStatus>? statusById,
    Map<String, EvidenceFileResult>? resultById,
    List<EvidenceIngestedFile>? pendingDuplicateAdds,
    String? warningMessage,
    bool clearWarning = false,
  }) {
    return EvidenceState(
      files: files ?? this.files,
      statusById: statusById ?? this.statusById,
      resultById: resultById ?? this.resultById,
      pendingDuplicateAdds: pendingDuplicateAdds ?? this.pendingDuplicateAdds,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }
}

class EvidenceController extends Notifier<EvidenceState> {
  @override
  EvidenceState build() => const EvidenceState();

  int _fnv1a32(List<int> input) {
    var hash = 0x811c9dc5;
    for (final b in input) {
      hash ^= (b & 0xff);
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  int _dedupeHash({required String name, required int? size, required Uint8List? bytes, required String? path}) {
    if (bytes != null && bytes.isNotEmpty) {
      return _fnv1a32(bytes);
    }
    final s = '${name.toLowerCase()}|${size ?? -1}|${path ?? ''}';
    return _fnv1a32(utf8.encode(s));
  }

  bool _looksLikeExport(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.csv') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.pdf');
  }

  Future<void> ingestSharedPaths(List<String> paths) async {
    final additions = <EvidenceIngestedFile>[];
    for (final p in paths) {
      final name = p.split(RegExp(r'[\\/]')).last;
      final hash = _dedupeHash(name: name, size: null, bytes: null, path: p);
      additions.add(
        EvidenceIngestedFile(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          path: p,
          bytes: null,
          source: EvidenceSource.shared,
          addedAt: DateTime.now(),
          dedupeHash: hash,
        ),
      );
    }
    _addFiles(additions);
  }

  Future<void> addFromGallery(List<XFile> picks) async {
    final additions = <EvidenceIngestedFile>[];
    for (final x in picks) {
      Uint8List? bytes;
      try {
        bytes = await x.readAsBytes();
      } catch (_) {
        bytes = null;
      }
      final name = x.name;
      final hash = _dedupeHash(name: name, size: bytes?.length, bytes: bytes, path: x.path);

      additions.add(
        EvidenceIngestedFile(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          path: x.path,
          bytes: bytes,
          source: EvidenceSource.screenshot,
          addedAt: DateTime.now(),
          dedupeHash: hash,
        ),
      );
    }
    _addFiles(additions);
  }

  Future<void> addFromFilePicker(List<PlatformFile> picks) async {
    final additions = <EvidenceIngestedFile>[];
    for (final p in picks) {
      final bytes = p.bytes;
      final hash = _dedupeHash(name: p.name, size: p.size, bytes: bytes, path: p.path);
      additions.add(
        EvidenceIngestedFile(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: p.name,
          path: p.path,
          bytes: bytes,
          source: _looksLikeExport(p.name) ? EvidenceSource.export : EvidenceSource.screenshot,
          addedAt: DateTime.now(),
          dedupeHash: hash,
        ),
      );
    }
    _addFiles(additions);
  }

  void _addFiles(List<EvidenceIngestedFile> additions) {
    if (additions.isEmpty) return;

    final existingHashes = state.files.map((e) => e.dedupeHash).toSet();
    final nonDupes = <EvidenceIngestedFile>[];
    final dupes = <EvidenceIngestedFile>[];

    for (final a in additions) {
      if (existingHashes.contains(a.dedupeHash)) {
        dupes.add(a);
      } else {
        nonDupes.add(a);
      }
    }

    final nextFiles = [...state.files, ...nonDupes];
    final nextStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
    for (final f in nonDupes) {
      nextStatus[f.id] = EvidenceProcessingStatus.idle;
    }

    state = state.copyWith(
      files: nextFiles,
      statusById: nextStatus,
      pendingDuplicateAdds: dupes.isNotEmpty ? dupes : state.pendingDuplicateAdds,
      warningMessage: dupes.isNotEmpty ? 'Duplicate files detected.' : null,
      clearWarning: dupes.isEmpty,
    );
  }

  void addDuplicatesAnyway() {
    if (state.pendingDuplicateAdds.isEmpty) return;

    final nextFiles = [...state.files, ...state.pendingDuplicateAdds];
    final nextStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
    for (final f in state.pendingDuplicateAdds) {
      nextStatus[f.id] = EvidenceProcessingStatus.idle;
    }

    state = state.copyWith(
      files: nextFiles,
      statusById: nextStatus,
      pendingDuplicateAdds: const <EvidenceIngestedFile>[],
      warningMessage: 'Duplicates added anyway.',
    );
  }

  void discardDuplicates() {
    if (state.pendingDuplicateAdds.isEmpty) return;
    state = state.copyWith(
      pendingDuplicateAdds: const <EvidenceIngestedFile>[],
      warningMessage: 'Duplicates skipped.',
    );
  }

  void removeFile(String id) {
    final nextFiles = state.files.where((f) => f.id != id).toList(growable: false);
    final nextStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
    final nextResult = Map<String, EvidenceFileResult>.from(state.resultById);
    nextStatus.remove(id);
    nextResult.remove(id);
    state = state.copyWith(files: nextFiles, statusById: nextStatus, resultById: nextResult);
  }

  Future<void> processFile(String id) async {
    final file = state.files.where((f) => f.id == id).firstOrNull;
    if (file == null) return;

    final nextStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
    nextStatus[id] = EvidenceProcessingStatus.processing;
    state = state.copyWith(statusById: nextStatus, clearWarning: true);

    try {
      // Persist raw evidence metadata (type + path) for the day.
      final evidenceRepo = ref.read(evidenceRepositoryProvider);
      final accountId = ref.read(sessionProvider).accountKey;
      final type = switch (file.source) {
        EvidenceSource.export => 'export',
        EvidenceSource.shared => 'shared',
        EvidenceSource.screenshot => 'screenshot',
      };
      await evidenceRepo.saveEvidence(type, file.path ?? file.name, accountId: accountId);

      // Real OCR: extract payment amounts from the uploaded image
      final amounts = await _extractAmountsFromFile(file);

      final nextResult = Map<String, EvidenceFileResult>.from(state.resultById);
      nextResult[id] = EvidenceFileResult(amounts: amounts);

      final doneStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
      doneStatus[id] = EvidenceProcessingStatus.done;

      state = state.copyWith(statusById: doneStatus, resultById: nextResult);
    } catch (e) {
      final nextResult = Map<String, EvidenceFileResult>.from(state.resultById);
      nextResult[id] = const EvidenceFileResult(errorMessage: 'Needs clearer image');

      final errStatus = Map<String, EvidenceProcessingStatus>.from(state.statusById);
      errStatus[id] = EvidenceProcessingStatus.error;

      state = state.copyWith(
        statusById: errStatus,
        resultById: nextResult,
        warningMessage: 'Processing failed for one file.',
      );
    }
  }

  Future<void> processAllPending() async {
    final pendingIds = state.files
        .where((file) {
          final status = state.statusById[file.id] ?? EvidenceProcessingStatus.idle;
          return status == EvidenceProcessingStatus.idle || status == EvidenceProcessingStatus.error;
        })
        .map((file) => file.id)
        .toList(growable: false);

    for (final id in pendingIds) {
      await processFile(id);
    }
  }

  void updateExtractedAmount(String fileId, String amountId, double nextAmount) {
    final current = state.resultById[fileId];
    if (current == null) return;

    final nextAmounts = current.amounts
        .map(
          (a) => a.id == amountId
              ? ExtractedAmount(id: a.id, amount: nextAmount, trustLabel: a.trustLabel)
              : a,
        )
        .toList(growable: false);

    final nextResult = Map<String, EvidenceFileResult>.from(state.resultById);
    nextResult[fileId] = EvidenceFileResult(amounts: nextAmounts, errorMessage: current.errorMessage);
    state = state.copyWith(resultById: nextResult);
  }

  // ── OCR helpers ────────────────────────────────────────────────────────────

  Future<List<ExtractedAmount>> _extractAmountsFromFile(EvidenceIngestedFile file) async {
    if (kIsWeb) return const <ExtractedAmount>[];

    final path = file.path;
    if (path == null || path.trim().isEmpty) return const <ExtractedAmount>[];

    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();
      return _parseAmountsFromText(recognized.text);
    } catch (_) {
      return const <ExtractedAmount>[];
    }
  }

  List<ExtractedAmount> _parseAmountsFromText(String rawText) {
    const uuid = Uuid();
    final text = rawText.replaceAll('\n', ' ');

    // Priority 1: amounts adjacent to payment keywords
    final contextPattern = RegExp(
      r'(?:total|jumlah|amount|bayaran|payment|received|dibayar|transfer|charged|tolak)'
      r'\s*[:\-]?\s*(?:RM|MYR)?\s*(\d{1,6}(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    );
    // Priority 2: RM / MYR prefixed values
    final rmPattern = RegExp(
      r'(?:RM|MYR)\s*(\d{1,6}(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    );

    final found = <double, String>{};

    for (final m in contextPattern.allMatches(text)) {
      final raw = (m.group(1) ?? '').replaceAll(',', '.');
      final v = double.tryParse(raw);
      if (v != null && v >= 0.10) found[v] = 'Total amount';
    }
    for (final m in rmPattern.allMatches(text)) {
      final raw = (m.group(1) ?? '').replaceAll(',', '.');
      final v = double.tryParse(raw);
      if (v != null && v >= 0.10 && !found.containsKey(v)) {
        found[v] = 'Payment detected';
      }
    }

    // Sort largest-first (the overall total is usually the biggest number)
    final entries = found.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final result = <ExtractedAmount>[];
    for (var i = 0; i < entries.length && i < 5; i++) {
      result.add(ExtractedAmount(
        id: uuid.v4(),
        amount: entries[i].key,
        trustLabel: entries[i].value,
      ));
    }
    return result;
  }
}

final evidenceProvider =
    NotifierProvider<EvidenceController, EvidenceState>(
  EvidenceController.new,
);

extension FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
