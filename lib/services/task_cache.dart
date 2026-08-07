import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/models/task.dart';

class TaskCache {
  TaskCache({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _tasksKey = 'tasks_cache';
  static const _cachedAtKey = 'tasks_cached_at';

  final SharedPreferencesAsync _preferences;

  Future<List<Task>?> read({required Duration maxAge}) async {
    final tasksJson = await _preferences.getString(_tasksKey);
    final cachedAtMilliseconds = await _preferences.getInt(_cachedAtKey);

    if (tasksJson == null || cachedAtMilliseconds == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMilliseconds);
    if (DateTime.now().difference(cachedAt) >= maxAge) {
      await clear();
      return null;
    }

    try {
      final jsonList = jsonDecode(tasksJson) as List<dynamic>;
      return jsonList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    }
  }

  Future<void> write(List<Task> tasks) async {
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await _preferences.setString(_tasksKey, tasksJson);
    await _preferences.setInt(
      _cachedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clear() async {
    await _preferences.remove(_tasksKey);
    await _preferences.remove(_cachedAtKey);
  }
}
