import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
        backgroundColor: Color(0xFFE13D56),
      ),
      body: Center(
        child: Text(
          'Welcome to the next page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
