import 'package:flutter/foundation.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/exceptions/api_exception.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this.taskService});

  final TaskService taskService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  ApiException? _error;

  List<Task> get tasks => List.unmodifiable(
    _tasks,
  ); //dışardaki kod görevleri okuyabilir ama doğrudan değiştiremez
  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  void _setError(Object error) {
    if (error is ApiException) {
      _error = error;
    } else {
      _error = const ApiException(messageKey: 'generic_error');
    }
  }

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await taskService.getTasks(forceRefresh: forceRefresh);
    } catch (error) {
      _setError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdTask = await taskService.createTask(task);

      _tasks.insert(0, createdTask);

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _error = null;
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
      _setError(error);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await taskService.deleteTask(id);

      _tasks.removeWhere((task) => task.id == id);

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
