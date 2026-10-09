import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheEntry {
  const CacheEntry(this.data, this.savedAt);
  final Map<String, dynamic> data;
  final DateTime savedAt;
}

/// Caché JSON clave/valor para el modo offline.
class CacheStorage {
  CacheStorage(this._prefs);

  static const _prefix = 'cache_v1_';
  final SharedPreferences _prefs;

  Future<void> write(String key, Map<String, dynamic> data) =>
      _prefs.setString(
        '$_prefix$key',
        jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'data': data}),
      );

  CacheEntry? read(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntry(
        Map<String, dynamic>.from(map['data'] as Map),
        DateTime.parse(map['saved_at'] as String),
      );
    } catch (_) {
      return null; // caché corrupta = sin caché
    }
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
