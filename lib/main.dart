import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/pages/task_list_page.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:easy_localization/easy_localization.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://jsonplaceholder.typicode.com',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final taskService = TaskService(baseUrl: apiBaseUrl);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: MyApp(taskService: taskService),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.taskService, super.key});

  final TaskService taskService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(taskService: taskService),
      child: MaterialApp(
        title: 'app_title'.tr(),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const TaskListPage(),
      ),
    );
  }
}
