import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_card.dart';

void main() {
  test('Task JSON verisine dönüşür ve geri oluşturulur', () {
    final task = Task(id: 7, userId: 2, title: 'Test görevi', completed: true);
    final restored = Task.fromJson(task.toJson());

    expect(restored.id, 7);
    expect(restored.userId, 2);
    expect(restored.title, 'Test görevi');
    expect(restored.completed, isTrue);
  });

  testWidgets('TaskCard görev bilgilerini gösterir', (tester) async {
    final task = Task(
      id: 1,
      userId: 3,
      title: 'Alışveriş yap',
      completed: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TaskCard(task: task, onTap: () {})),
      ),
    );

    expect(find.text('Alışveriş yap'), findsOneWidget);
    expect(find.text('Kullanıcı: 3'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });
}
