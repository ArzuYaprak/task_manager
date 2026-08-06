import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/constants/text_constants.dart';
import 'package:task_manager/pages/create_task_page.dart';
import 'package:task_manager/pages/task_detail_page.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/widgets/task_card.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(TextConstants.tasks)),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isLoading
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateTaskPage(),
                ),
              ),
        icon: const Icon(Icons.add),
        label: const Text(TextConstants.newTask),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading && provider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 12),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.fetchTasks,
                icon: const Icon(Icons.refresh),
                label: const Text(TextConstants.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.tasks.isEmpty) {
      return const Center(child: Text(TextConstants.noTasks));
    }
    return RefreshIndicator(
      onRefresh: provider.fetchTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return TaskCard(
            task: task,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskDetailPage(taskId: task.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
