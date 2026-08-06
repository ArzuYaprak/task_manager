import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task_manager/models/task.dart';

class TaskService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Görevler alınamadı: ${response.statusCode}');
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Görev oluşturulamadı: ${response.statusCode}');
  }

  Future<Task> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Güncellenecek görevin ID değeri bulunamadı.');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/todos/${task.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Görev güncellenemedi: ${response.statusCode}');
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Görev silinemedi: ${response.statusCode}');
    }
  }
}
