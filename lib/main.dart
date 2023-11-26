import 'package:flutter/material.dart';
import 'roulette_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'コンセプト縛りCypher',
      home: RoulettePage(),
    );
  }
}
