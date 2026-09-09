import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'database_helper.dart';

class SyncService {
  static const _lastSyncKey = 'last_synced_server_time';

  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> sync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    final since = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;

    final result = await _api.fetchContent(since: since);

    if (result.items.isNotEmpty) {
      await _db.upsertItems(result.items);
    }

    // Altijd overschrijven, ongeacht of er wijzigingen waren.
    await prefs.setString(_lastSyncKey, result.serverTime.toIso8601String());
  }
}
