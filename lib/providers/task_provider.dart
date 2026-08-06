import 'package:flutter/foundation.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskService? taskService})
    : taskService = taskService ?? TaskService();

  final TaskService taskService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await taskService.getTasks();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTask = await taskService.createTask(task);

      _tasks.insert(0, createdTask);

      return true;
    } catch (error) {
      _errorMessage = error.toString();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await taskService.updateTask(task);

      final index = _tasks.indexWhere(
        (currentTask) => currentTask.id == updatedTask.id,
      );

      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      return true;
    } catch (error) {
      _errorMessage = error.toString();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await taskService.deleteTask(id);

      _tasks.removeWhere((task) => task.id == id);

      return true;
    } catch (error) {
      _errorMessage = error.toString();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
