import 'dart:convert';
import 'package:task_manager/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_cache.dart';

class TaskService {
  TaskService({
    required String baseUrl,
    http.Client? client,
    TaskCache? cache,
    this.cacheDuration = const Duration(minutes: 5),
  })
    : _baseUrl = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/'),
      _client = client ?? http.Client(),
      _cache = cache ?? TaskCache();

  final Uri _baseUrl;
  final http.Client _client;
  final TaskCache _cache;
  final Duration cacheDuration;

  Uri _uri(String path) => _baseUrl.resolve(path);

  Future<List<Task>> getTasks({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedTasks = await _cache.read(maxAge: cacheDuration);
      if (cachedTasks != null) return cachedTasks;
    }

    final response = await _client.get(_uri('todos'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      final tasks = jsonList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
      await _cache.write(tasks);
      return tasks;
    }
    throw ApiException(
      messageKey: 'fetch_tasks_error',
      statusCode: response.statusCode,
    );
  }

  Future<Task> createTask(Task task) async {
    final response = await _client.post(
      _uri('todos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      final createdTask = Task.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _cache.clear();
      return createdTask;
    }
    throw ApiException(
      messageKey: 'create_task_error',
      statusCode: response.statusCode,
    );
  }

  Future<Task> updateTask(Task task) async {
    if (task.id == null) {
      throw const ApiException(messageKey: 'missing_task_id');
    }
    final response = await _client.put(
      _uri('todos/${task.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      final updatedTask = Task.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _cache.clear();
      return updatedTask;
    }
    throw ApiException(
      messageKey: 'update_task_error',
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteTask(int id) async {
    final response = await _client.delete(_uri('todos/$id'));
    if (response.statusCode != 200) {
      throw ApiException(
        messageKey: 'delete_task_error',
        statusCode: response.statusCode,
      );
    }
    await _cache.clear();
  }
}
