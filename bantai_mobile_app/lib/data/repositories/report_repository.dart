import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/api_client.dart';
import '../../core/connectivity_service.dart';
import '../local/app_database.dart';
import '../models/report.dart';

class NewReportInput {
  final String categoryId;
  final String? subcategoryId;
  final String title;
  final String description;
  final String? address;
  final double lat;
  final double lng;
  final String? lguId;
  final String? barangayId;
  final List<File> photos;

  NewReportInput({
    required this.categoryId,
    this.subcategoryId,
    required this.title,
    required this.description,
    this.address,
    required this.lat,
    required this.lng,
    this.lguId,
    this.barangayId,
    required this.photos,
  });
}

/// Either the report synced immediately (we have the server's copy, with
/// its real ID and AI-assessed severity), or it's queued locally and will
/// sync automatically once back online (see ReportSyncService).
sealed class SubmissionResult {}

class SubmissionSynced extends SubmissionResult {
  final Report report;
  SubmissionSynced(this.report);
}

class SubmissionQueued extends SubmissionResult {
  final String clientUuid;
  SubmissionQueued(this.clientUuid);
}

class ReportRepository {
  ReportRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<SubmissionResult> submitReport(NewReportInput input) async {
    final clientUuid = _uuid.v4();
    final deviceSubmittedAt = DateTime.now();
    final online = await ConnectivityService.instance.isOnline();

    if (online) {
      try {
        final report = await _submitToServer(
          clientUuid: clientUuid,
          input: input,
          deviceSubmittedAt: deviceSubmittedAt,
          photoPaths: input.photos.map((f) => f.path).toList(),
        );
        return SubmissionSynced(report);
      } on ApiException catch (e) {
        if (!e.isNetworkError) rethrow; // a real validation/permission error — surface it, don't queue it
        // fall through to offline queueing below
      }
    }

    final savedPaths = await _persistPhotosLocally(clientUuid, input.photos);
    await _db.into(_db.pendingReports).insert(PendingReportsCompanion.insert(
          clientUuid: clientUuid,
          categoryId: input.categoryId,
          subcategoryId: drift.Value(input.subcategoryId),
          title: drift.Value(input.title),
          description: input.description,
          address: drift.Value(input.address),
          lat: input.lat,
          lng: input.lng,
          lguId: drift.Value(input.lguId),
          barangayId: drift.Value(input.barangayId),
          photoPathsJson: drift.Value(jsonEncode(savedPaths)),
          deviceSubmittedAt: deviceSubmittedAt,
        ));

    return SubmissionQueued(clientUuid);
  }

  /// Used by ReportSyncService to retry a queued report — same server call,
  /// just sourced from the Drift row instead of fresh form input.
  Future<Report> _submitToServer({
    required String clientUuid,
    required NewReportInput input,
    required DateTime deviceSubmittedAt,
    required List<String> photoPaths,
  }) async {
    final form = FormData.fromMap({
      'clientUuid': clientUuid,
      'categoryId': input.categoryId,
      if (input.subcategoryId != null) 'subcategoryId': input.subcategoryId,
      'title': input.title,
      'description': input.description,
      if (input.address != null) 'address': input.address,
      'lat': input.lat.toString(),
      'lng': input.lng.toString(),
      if (input.lguId != null) 'lguId': input.lguId,
      if (input.barangayId != null) 'barangayId': input.barangayId,
      'deviceSubmittedAt': deviceSubmittedAt.toIso8601String(),
      'photos': [
        for (final path in photoPaths)
          if (File(path).existsSync()) await MultipartFile.fromFile(path, filename: p.basename(path)),
      ],
    });

    final res = await ApiClient.instance.post('/reports', data: form);
    return Report.fromJson(res['report'] as Map<String, dynamic>);
  }

  Future<List<String>> _persistPhotosLocally(String clientUuid, List<File> photos) async {
    final dir = await getApplicationDocumentsDirectory();
    final queueDir = Directory(p.join(dir.path, 'pending_report_photos', clientUuid));
    await queueDir.create(recursive: true);

    final saved = <String>[];
    for (var i = 0; i < photos.length; i++) {
      final dest = p.join(queueDir.path, 'photo_$i${p.extension(photos[i].path)}');
      await photos[i].copy(dest);
      saved.add(dest);
    }
    return saved;
  }

  // -- Read operations (online only — see note in ReportSyncService about
  //    why offline browsing of the server's report list isn't in scope here) --
  Future<List<Report>> list({Map<String, String>? filters}) async {
    final res = await ApiClient.instance.get('/reports', query: filters);
    return (res['reports'] as List).map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Report> get(String id) async {
    final res = await ApiClient.instance.get('/reports/$id');
    return Report.fromJson(res['report'] as Map<String, dynamic>);
  }

  Future<int> pendingCount() async {
    final rows = await _db.select(_db.pendingReports).get();
    return rows.length;
  }

  /// Used by ReportSyncService: retries one queued row against the server,
  /// using the same submission path as a fresh online submit (including the
  /// clientUuid idempotency guard, so a retry after a partial failure never
  /// creates a duplicate report).
  Future<Report> retryQueuedRow(PendingReport row) async {
    final photoPaths = List<String>.from(jsonDecode(row.photoPathsJson) as List);

    return _submitToServer(
      clientUuid: row.clientUuid,
      input: NewReportInput(
        categoryId: row.categoryId,
        subcategoryId: row.subcategoryId,
        title: row.title,
        description: row.description,
        address: row.address,
        lat: row.lat,
        lng: row.lng,
        lguId: row.lguId,
        barangayId: row.barangayId,
        photos: const [], // paths passed separately below — files may have moved, see photoPaths
      ),
      deviceSubmittedAt: row.deviceSubmittedAt,
      photoPaths: photoPaths,
    );
  }

  AppDatabase get database => _db;
}
