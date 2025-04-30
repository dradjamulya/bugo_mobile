import 'package:flutter/material.dart';
import 'dart:async';
import 'screens/auth-screen/login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE13D56),
      body: Center(
        child: Image.asset(
          'assets/logo-teks-mob-bugo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}