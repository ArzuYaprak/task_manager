import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/pages/delete_task_page.dart';
import 'package:task_manager/pages/update_task_page.dart';
import 'package:task_manager/providers/task_provider.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Görev detayı')),
        body: const Center(child: Text('Görev artık mevcut değil.')),
      );
    }
    final task = tasks[index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev detayı'),
        actions: [
          IconButton(
            tooltip: 'Düzenle',
            onPressed: () => _openUpdate(context, task),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Sil',
            onPressed: () => _openDelete(context, task),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            task.completed ? Icons.task_alt : Icons.pending_outlined,
            size: 72,
            color: task.completed ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          _InfoRow(label: 'Görev ID', value: '${task.id}'),
          _InfoRow(label: 'Kullanıcı ID', value: '${task.userId}'),
          _InfoRow(
            label: 'Durum',
            value: task.completed ? 'Tamamlandı' : 'Devam ediyor',
          ),
        ],
      ),
    );
  }

  Future<void> _openUpdate(BuildContext context, Task task) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => UpdateTaskPage(task: task)),
    );
  }

  Future<void> _openDelete(BuildContext context, Task task) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => DeleteTaskPage(task: task)),
    );
    if (deleted == true && context.mounted) Navigator.of(context).pop();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
