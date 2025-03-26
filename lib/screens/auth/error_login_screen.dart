import 'package:flutter/material.dart';
import '/home_screen.dart';
import 'register_screen.dart';

class ErrorLoginScreen extends StatelessWidget {
  const ErrorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/login-screen-bg-mob-bugo.png',
                fit: BoxFit.cover,
              ),
            ),

            // Login Form
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 5),
                  // Welcome Text
                  Text(
                    "Make sure you filled them correctly!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE13D56),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Username Field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'USERNAME',
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Password Field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'PASSWORD',
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Register Text (Style sama dengan welcome text)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterScreen()
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don’t have an account, Bud? ",
                        style: TextStyle(
                          fontSize: 18, // Ukuran disamakan
                          fontWeight: FontWeight.bold, // Bold disamakan
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              fontSize: 18, // Ukuran disamakan
                              fontWeight: FontWeight.bold, // Bold disamakan
                              color: Color(0xFF9D8DF1), // Warna ungu
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 34),

                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const HomeScreen()
                        ),
                      );
                    },
                    child: Text(
                      'LOG IN',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}