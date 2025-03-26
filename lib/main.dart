import 'package:flutter/material.dart';
import 'loading_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUGO App',
      theme: ThemeData(
        primaryColor: Color(0xFFE13D56),
      ),
      home: LoadingScreen(),
    );
  }
}