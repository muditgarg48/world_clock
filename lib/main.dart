import 'package:flutter/material.dart';

import 'package:world_clock/world_clock.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WorldClock(title: 'World Clock'),
    );
  }
}
