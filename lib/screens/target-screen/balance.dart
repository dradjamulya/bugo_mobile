import 'package:flutter/material.dart';

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Page'),
        backgroundColor: Color(0xFFE13D56),
      ),
      body: Center(
        child: Text(
          'Welcome to the balance page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
