import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../core/api_client.dart';
import '../../core/connectivity_service.dart';
import '../local/app_database.dart';
import 'report_repository.dart';

/// Drains the Drift offline queue whenever the device reconnects (or the
/// app resumes). This is the piece that makes "report while offline, it
/// sends itself once you're back online" actually work.
///
/// Deliberately simple for a v1: sequential (not parallel) uploads, so a
/// flaky connection doesn't fire five multipart uploads at once, and a
/// retry cap so a permanently-broken row (e.g. a category that got deleted
/// server-side) doesn't spin forever on every connectivity blip.
class ReportSyncService extends ChangeNotifier {
  ReportSyncService(this._repo);

  final ReportRepository _repo;
  bool _syncing = false;
  int _lastQueueLength = 0;
  StreamSubscription<bool>? _connectivitySub;

  bool get isSyncing => _syncing;
  int get lastKnownQueueLength => _lastQueueLength;

  void start() {
    _connectivitySub = ConnectivityService.instance.onStatusChange.listen((online) {
      if (online) syncNow();
    });
    syncNow(); // also attempt once at startup, in case we launched already online with a stale queue
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    if (!await ConnectivityService.instance.isOnline()) return;

    _syncing = true;
    notifyListeners();

    try {
      final db = _repo.database;
      final rows = await (db.select(db.pendingReports)
            ..where((t) => t.status.isIn(['queued', 'failed']))
            ..orderBy([(t) => OrderingTerm.asc(t.deviceSubmittedAt)]))
          .get();

      for (final row in rows) {
        // Skip rows that have failed a lot — avoid hammering a request
        // that's failing for a non-network reason (e.g. bad data) on every
        // single reconnect. They stay visible to the user as "failed" and
        // can be retried manually — see the pending-reports screen.
        if (row.retryCount >= 5) continue;

        await (db.update(db.pendingReports)..where((t) => t.clientUuid.equals(row.clientUuid)))
            .write(const PendingReportsCompanion(status: Value('syncing')));

        try {
          await _repo.retryQueuedRow(row);
          await _cleanUpSyncedRow(row);
        } on ApiException catch (e) {
          if (e.isNetworkError) {
            // Connection dropped again mid-sync — stop this pass entirely
            // rather than marking every remaining row as failed.
            await (db.update(db.pendingReports)..where((t) => t.clientUuid.equals(row.clientUuid)))
                .write(const PendingReportsCompanion(status: Value('queued')));
            break;
          }
          await (db.update(db.pendingReports)..where((t) => t.clientUuid.equals(row.clientUuid))).write(
            PendingReportsCompanion(
              status: const Value('failed'),
              retryCount: Value(row.retryCount + 1),
              lastError: Value(e.message),
            ),
          );
        }
      }

      _lastQueueLength = await _repo.pendingCount();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> _cleanUpSyncedRow(PendingReport row) async {
    final db = _repo.database;
    await (db.delete(db.pendingReports)..where((t) => t.clientUuid.equals(row.clientUuid))).go();

    // Delete the locally-cached photos now that they live on the server —
    // non-fatal if this fails, orphaned local files are just a disk-space
    // nuisance, not a correctness problem.
    try {
      final paths = List<String>.from(jsonDecode(row.photoPathsJson) as List);
      for (final path in paths) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      if (paths.isNotEmpty) {
        final queueDir = Directory(p.dirname(paths.first));
        if (await queueDir.exists() && (await queueDir.list().toList()).isEmpty) {
          await queueDir.delete();
        }
      }
    } catch (_) {
      // see comment above
    }
  }
}
