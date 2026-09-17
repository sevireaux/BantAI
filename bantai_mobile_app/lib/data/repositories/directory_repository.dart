import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../core/api_client.dart';
import '../../core/connectivity_service.dart';
import '../local/app_database.dart';
import '../models/models.dart';

/// Fetches categories/LGUs/barangays online and caches them into Drift, so
/// the report form's pickers still work offline using the last-known data
/// — a citizen can file a complete report with no connection at all.
class DirectoryRepository {
  DirectoryRepository(this._db);
  final AppDatabase _db;

  Future<List<ApiCategory>> getCategories() async {
    if (await ConnectivityService.instance.isOnline()) {
      try {
        final res = await ApiClient.instance.get('/categories');
        final categories = (res['categories'] as List).map((e) => ApiCategory.fromJson(e)).toList();
        await _cacheCategories(categories);
        return categories;
      } catch (_) {
        // fall through to cache
      }
    }
    return _cachedCategories();
  }

  Future<List<PublicLgu>> getLgus() async {
    if (await ConnectivityService.instance.isOnline()) {
      try {
        final res = await ApiClient.instance.get('/lgus');
        final lgus = (res['lgus'] as List).map((e) => PublicLgu.fromJson(e)).toList();
        await _db.batch((batch) {
          batch.deleteAll(_db.cachedLgus);
          batch.insertAll(_db.cachedLgus, lgus.map((l) => CachedLgusCompanion.insert(id: l.id, name: l.name)));
        });
        return lgus;
      } catch (_) {
        // fall through to cache
      }
    }
    final rows = await _db.select(_db.cachedLgus).get();
    return rows.map((r) => PublicLgu(id: r.id, name: r.name)).toList();
  }

  Future<List<PublicBarangay>> getBarangays(String lguId) async {
    if (await ConnectivityService.instance.isOnline()) {
      try {
        final res = await ApiClient.instance.get('/barangays', query: {'lguId': lguId});
        final barangays = (res['barangays'] as List).map((e) => PublicBarangay.fromJson(e)).toList();
        await _db.batch((batch) {
          batch.deleteWhere(_db.cachedBarangays, (t) => t.lguId.equals(lguId));
          batch.insertAll(
            _db.cachedBarangays,
            barangays.map((b) => CachedBarangaysCompanion.insert(id: b.id, lguId: lguId, name: b.name)),
          );
        });
        return barangays;
      } catch (_) {
        // fall through to cache
      }
    }
    final rows = await (_db.select(_db.cachedBarangays)..where((t) => t.lguId.equals(lguId))).get();
    return rows.map((r) => PublicBarangay(id: r.id, name: r.name)).toList();
  }

  Future<void> _cacheCategories(List<ApiCategory> categories) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.cachedCategories);
      batch.insertAll(
        _db.cachedCategories,
        categories.map((c) => CachedCategoriesCompanion.insert(
              id: c.id,
              name: c.name,
              subcategoriesJson: drift.Value(jsonEncode(c.subcategories.map((s) => {'id': s.id, 'name': s.name}).toList())),
            )),
      );
    });
  }

  Future<List<ApiCategory>> _cachedCategories() async {
    final rows = await _db.select(_db.cachedCategories).get();
    return rows
        .map((r) => ApiCategory(
              id: r.id,
              name: r.name,
              subcategories: (jsonDecode(r.subcategoriesJson) as List)
                  .map((e) => Subcategory(id: e['id'], name: e['name']))
                  .toList(),
            ))
        .toList();
  }
}
