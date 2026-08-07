import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/extensions/api_exception_localization.dart';

class UpdateTaskPage extends StatefulWidget {
  const UpdateTaskPage({super.key, required this.task});

  final Task task;

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _userIdController;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _userIdController = TextEditingController(text: '${widget.task.userId}');
    _completed = widget.task.completed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();
    final success = await provider.updateTask(
      Task(
        id: widget.task.id,
        userId: int.parse(_userIdController.text.trim()),
        title: _titleController.text.trim(),
        completed: _completed,
      ),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error?.localizedMessage() ?? 'generic_error'.tr(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: Text('edit_task'.tr())),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'task_title'.tr()),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'task_title_required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'user_id'.tr()),
              validator: (value) {
                final id = int.tryParse(value?.trim() ?? '');
                return id == null || id <= 0 ? 'valid_id_required'.tr() : null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('completed'.tr()),
              value: _completed,
              onChanged: isLoading
                  ? null
                  : (value) => setState(() => _completed = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isLoading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text('save_changes'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
