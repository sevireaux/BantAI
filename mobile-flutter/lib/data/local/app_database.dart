import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// A report created while offline (or while online but the request failed
/// outright before reaching the server). `photoPaths` stores local file
/// paths as a JSON-encoded list — the actual images stay in app storage
/// until the sync succeeds, at which point ReportSyncService uploads them
/// and deletes the local copies.
///
/// `status` lifecycle: queued -> syncing -> (synced, then row is deleted)
///                                        -> failed (kept for retry / manual review)
class PendingReports extends Table {
  TextColumn get clientUuid => text()(); // generated on-device; doubles as server idempotency key
  TextColumn get categoryId => text()();
  TextColumn get subcategoryId => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text()();
  TextColumn get address => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get lguId => text().nullable()();
  TextColumn get barangayId => text().nullable()();
  TextColumn get photoPathsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get deviceSubmittedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {clientUuid};
}

/// Cached read-only reference data so the report form still works offline
/// — a citizen can pick a category/LGU/barangay even with no connection,
/// using whatever was last fetched while online.
class CachedCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get subcategoriesJson => text().withDefault(const Constant('[]'))(); // [{id,name}]

  @override
  Set<Column> get primaryKey => {id};
}

class CachedLgus extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedBarangays extends Table {
  TextColumn get id => text()();
  TextColumn get lguId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PendingReports, CachedCategories, CachedLgus, CachedBarangays])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bantai_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
