import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:task_manager/extensions/api_exception_localization.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _userIdController = TextEditingController(text: '1');
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
      appBar: AppBar(title: Text('new_task'.tr())),
      body: SafeArea(
        child: Form(
          //Metin alanlarını tek bir form altında toplar ve topluca doğrulamayı sağlar.
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'task_title'.tr()),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'task_title_required'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                //telefonda sayısal klavye açılmasını ister, garanti etmek için validatorda kullanıldı
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'user_id'.tr()),
                validator: (value) {
                  final id = int.tryParse(value?.trim() ?? '');
                  return id == null || id <= 0
                      ? 'valid_id_required'.tr()
                      : null;
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
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text('save'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
