import 'package:bugo_mobile/screens/target-screen/input_screen.dart';
import 'package:flutter/material.dart';
import '../auth-screen/profile_screen.dart';
import '../home-screen/home_screen.dart';

class InputSavingsScreen extends StatelessWidget {
  const InputSavingsScreen({super.key});

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
                'assets/input-target-screen-bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Login Form
            Center(
              child: Column(
                children: [
                  SizedBox(height: 180),

                  // Add amount field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add Amount',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                  // Choose target to alocate savings field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Choose Target to Alocate Savings',
                      ),
                    ),
                  ),
                  SizedBox(height: 410),

                  // Save
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
                        MaterialPageRoute(builder: (context) => const InputScreen()
                        ),
                      );
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFE13D56),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        // tetap berada di page
                      },
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.black, 
                        size: 30,
                      ),
                    ),
                      
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: const Icon(
                        Icons.person,
                        color: Colors.white, 
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
