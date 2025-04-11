import 'package:bugo_mobile/screens/target-screen/input_savings_screen.dart';
import 'package:bugo_mobile/screens/target-screen/input_target_screen_step1.dart';
import 'package:flutter/material.dart';
import '../home-screen/home_screen.dart';
import '../auth-screen/profile_screen.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg-screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // **Konten Utama**
          Column(
            children: [
              const SizedBox(height: 90), // Jarak atas untuk "Hey, User!"
              const Center(
                child: Text(
                  'Which one will you add?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 25), // Jarak antara teks dan form

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      // Username Field
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New Target',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black, size: 15),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputTargetScreenStep1()),
                                );
                              },
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Name Field
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add Savings',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black, size: 15),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputSavingsScreen()),
                                );
                              },
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 224),

                      // **Copyright**
                      Text(
                        'Copyright© BUGO2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 50), // Jarak agar tidak menempel ke navigasi
                    ],
                  ),
                ),
              ),
            ],
          ),

          // **Navigasi Bawah**
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
                          // Tetap berada di page tanpa reload
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
    );
  }
}

class EditableIcon extends StatefulWidget {
  const EditableIcon({super.key});

  @override
  _EditableIconState createState() => _EditableIconState();
}

class _EditableIconState extends State<EditableIcon> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isEditing = !isEditing; // Toggle antara ikon edit dan centang
        });
      },
      child: CircleAvatar(
        radius: 5,
        backgroundColor: isEditing ? Colors.black : Colors.transparent,
        child: Icon(
          isEditing ? Icons.check : Icons.edit,
          color: isEditing ? Colors.white : Colors.black,
          size: 15,
        ),
      ),
    );
  }
}