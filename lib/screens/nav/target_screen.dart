import 'package:bugo_mobile/home_screen.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class TargetScreen extends StatelessWidget {
  const TargetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCFDF7), // cyan
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/header-target-screen.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 283, 
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Chip(
                            backgroundColor: Color(0xFF342E37), // hitam
                            label: Text("Flip", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Current Target :',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Text(
                        'Rp999.000.000.000',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Rp999.000.000.000',
                        style: TextStyle(
                          color: Color(0xFFFFED66), // kuning
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, color: Color(0xFFE13D56)), // pink
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // List Target
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), // putih
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ListTile(
                          title: const Text(
                            'Mobil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342E37), // hitam
                            ),
                          ),
                          subtitle: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp999.000.000.000 / Rp999.000.000.000',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9D8DF1), // ungu
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Completion Plan : 2027',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.star_border, size: 30),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                        MaterialPageRoute(builder: (context) =>
                        const HomeScreen())
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TargetScreen()),
                      );
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