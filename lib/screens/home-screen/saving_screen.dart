import 'package:flutter/material.dart';

class SavingScreen extends StatelessWidget {
  const SavingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SavingScreen'),
        backgroundColor: Color(0xFFE13D56),
      ),
      body: Center(
        child: Text(
          'Welcome to the saving page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
