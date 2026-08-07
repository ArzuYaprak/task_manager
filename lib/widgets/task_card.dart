import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';
import 'package:easy_localization/easy_localization.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.completed ? Colors.green : null,
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('user'.tr(namedArgs: {'id': task.userId.toString()})),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
