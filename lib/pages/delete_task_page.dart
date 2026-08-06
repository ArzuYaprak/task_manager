import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/constants/text_constants.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';

class DeleteTaskPage extends StatelessWidget {
  const DeleteTaskPage({super.key, required this.task});

  final Task task;

  Future<void> _delete(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    final success = await provider.deleteTask(task.id!);
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? TextConstants.genericError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(TextConstants.deleteTask)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                TextConstants.deleteConfirmation,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(task.title, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text(TextConstants.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: isLoading ? null : () => _delete(context),
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    label: const Text(TextConstants.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
