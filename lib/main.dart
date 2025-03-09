import 'package:flutter/material.dart';
import 'login_screen.dart'; 

void main() {
  runApp(const BrainifyApp());
}

class BrainifyApp extends StatelessWidget {
  const BrainifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brainify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF15162B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15162B),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const BrainifyLoginScreen(),
    );
  }
}