import 'package:flutter/material.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr. Blue',
      theme: ThemeData(
        fontFamily: 'Gotu',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Bottomnavigation(),
    );
  }
}
