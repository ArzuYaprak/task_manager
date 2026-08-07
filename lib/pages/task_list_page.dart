import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/pages/create_task_page.dart';
import 'package:task_manager/pages/task_detail_page.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/widgets/task_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:task_manager/extensions/api_exception_localization.dart';

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
      appBar: AppBar(
        title: Text('tasks'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'change_language'.tr(),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'tr'
                  ? const Locale('en')
                  : const Locale('tr');

              context.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isLoading
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CreateTaskPage()),
              ),
        icon: const Icon(Icons.add),
        label: Text('new_task'.tr()),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading && provider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 12),
              Text(
                provider.error!.localizedMessage(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.fetchTasks(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.tasks.isEmpty) {
      return Center(child: Text('no_tasks'.tr()));
    }
    return RefreshIndicator(
      onRefresh: () => provider.fetchTasks(forceRefresh: true),
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
