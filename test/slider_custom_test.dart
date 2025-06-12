import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:slider_slider/src/slider_view.dart';

void main() {
  testWidgets('SliderView renders correctly with images', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SliderView(
          imageWidgets: [
            Container(color: Colors.blue),
            Container(color: Colors.green),
          ],
          questions: const ['Test question?', 'Another question?'],
          answerButtonBuilder: (index) => [
            const Text('Custom Button'),
          ],
        ),
      ),
    );

    expect(find.text('Test question?'), findsOneWidget);
    expect(find.text('Custom Button'), findsOneWidget);
    expect(find.text('No images provided'), findsNothing);
  });

  testWidgets('SliderView shows empty message when no images provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SliderView(imageWidgets: []),
      ),
    );

    expect(find.text('No images provided'), findsOneWidget);
  });

  testWidgets('SliderView navigates with keyboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SliderView(
          imageWidgets: [
            Container(color: Colors.blue),
            Container(color: Colors.green),
            Container(color: Colors.red),
          ],
          onIndexChanged: (index) {
            expect(index, 1); // Expect index to change to 1
          },
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
  });
}