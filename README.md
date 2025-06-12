# my_custom_slider

A customizable Flutter carousel slider with smooth drag gestures, keyboard navigation, custom image widgets, and optional questions and answer buttons. Perfect for creating interactive image carousels, quizzes, or onboarding flows with a modern, animated UI.

## Features

- **Smooth Navigation**: Navigate through images using drag gestures or keyboard arrow keys (ideal for web and desktop apps).
- **Custom Image Widgets**: Supports any Flutter widget as carousel items, including `Image.asset`, `Image.network`, or custom UI elements.
- **Interactive Questions and Answers**: Display questions with customizable answer buttons for each slide.
- **Flexible Animations**: Configure animation curves and durations for smooth transitions.
- **Customizable Styling**: Adjust colors, padding, font sizes, and image dimensions to match your app’s design.
- **Accessibility**: Includes semantics for screen readers to improve accessibility.
- **No External Dependencies**: Lightweight and built with core Flutter widgets.

![Slider Demo](https://github.com/yourusername/my_custom_slider/raw/main/example/assets/demo.gif)

## Getting Started

### Prerequisites
- Flutter SDK: `>=3.0.0 <4.0.0`
- Dart SDK: `>=3.0.0 <4.0.0`
- A Flutter project to integrate the package.

### Installation
1. Add `my_custom_slider` to your `pubspec.yaml`:
   ```yaml
   dependencies:
     my_custom_slider: ^1.0.0


     flutter pub get
     import 'package:my_custom_slider/my_custom_slider.dart';

     import 'package:flutter/material.dart';
import 'package:my_custom_slider/my_custom_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Slider Example')),
        body: SliderView(
          imageWidgets: [
            Image.asset('assets/images/image1.jpg', fit: BoxFit.cover),
            Image.network('https://example.com/image2.jpg', fit: BoxFit.cover),
            Container(
              color: Colors.red,
              child: const Center(child: Text('Custom Widget')),
            ),
          ],
          questions: ['What is this?', 'Choose one:', 'Final question?'],
          answerButtonBuilder: (index) => [
            ElevatedButton(
              onPressed: () => print('Option 1'),
              child: const Text('Option 1'),
            ),
            ElevatedButton(
              onPressed: () => print('Option 2'),
              child: const Text('Option 2'),
            ),
          ],
          animationCurve: Curves.bounceOut,
          animationDuration: const Duration(milliseconds: 500),
          primaryColor: Colors.teal,
          secondaryColor: Colors.tealAccent,
          onIndexChanged: (index) => print('Current index: $index'),
        ),
      ),
    );
  }
}