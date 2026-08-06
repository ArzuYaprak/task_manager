import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/constants/text_constants.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _userIdController = TextEditingController(
    text: TextConstants.defaultUserId,
  );
  bool _completed = false;

  @override
  void dispose() {
    _titleController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();
    final success = await provider.createTask(
      Task(
        id: null,
        userId: int.parse(_userIdController.text.trim()),
        title: _titleController.text.trim(),
        completed: _completed,
      ),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text(TextConstants.newTask)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: TextConstants.taskTitle,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? TextConstants.taskTitleRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: TextConstants.userId,
                ),
                validator: (value) {
                  final id = int.tryParse(value?.trim() ?? '');
                  return id == null || id <= 0
                      ? TextConstants.validIdRequired
                      : null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(TextConstants.completed),
                value: _completed,
                onChanged: isLoading
                    ? null
                    : (value) => setState(() => _completed = value),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: isLoading ? null : _save,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text(TextConstants.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
