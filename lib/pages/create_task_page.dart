import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        SnackBar(content: Text(provider.errorMessage ?? 'Bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni görev')),
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
                decoration: const InputDecoration(labelText: 'Görev başlığı'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Görev başlığı zorunludur.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kullanıcı ID'),
                validator: (value) {
                  final id = int.tryParse(value?.trim() ?? '');
                  return id == null || id <= 0 ? 'Geçerli bir ID girin.' : null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tamamlandı'),
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
                label: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
