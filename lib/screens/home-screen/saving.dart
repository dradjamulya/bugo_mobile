import 'package:flutter/material.dart';

class Saving extends StatelessWidget {
  const Saving({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saving'),
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
