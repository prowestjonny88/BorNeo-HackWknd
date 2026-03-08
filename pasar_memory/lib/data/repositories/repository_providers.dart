import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'merchant_repo.dart';
import 'menu_repo.dart';
import 'order_repo.dart';
import 'evidence_repo.dart';
import 'extraction_repo.dart';
import 'recap_repo.dart';
import 'ledger_repo.dart';
import 'correction_repo.dart';
import '../../services/sync/sync_service.dart';

// --- Repositories ---
final merchantRepositoryProvider = Provider((ref) => MerchantRepository());
final menuRepositoryProvider = Provider((ref) => MenuRepository());
final orderRepositoryProvider = Provider((ref) => OrderRepository());
final evidenceRepositoryProvider = Provider((ref) => EvidenceRepository());
final extractionRepositoryProvider = Provider((ref) => ExtractionRepository());
final recapRepositoryProvider = Provider((ref) => RecapRepository());
final ledgerRepositoryProvider = Provider((ref) => LedgerRepository());
final correctionRepositoryProvider = Provider((ref) => CorrectionRepository());

// --- Services ---
final syncServiceProvider = Provider((ref) => SyncService());