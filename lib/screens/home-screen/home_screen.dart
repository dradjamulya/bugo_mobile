import 'package:flutter/material.dart';
import '../target-screen/target_screen.dart';
import '../auth-screen/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **Background gambar**
          Positioned.fill(
            child: Image.asset(
              'assets/bg-screen.png', 
              fit: BoxFit.cover,
            ),
          ),

          // **Isi konten di atas background**
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 90), // Jarak atas
              const Text(
                'Hey, User!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 80),

              // **Box Informasi**
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.savings,
                        size: 50,
                        color: Color(0xFFE13D56),
                      ),
                      const SizedBox(height: 24),

                      // **Box Current Saving**
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 70),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Current Saving for\n(Target Name):',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Rp999.000.000.000',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Rp999.000.000.000',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9D8DF1), // Warna ungu
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: const Color(0xFFE13D56),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 20),

                      // **Box Emergency Fund**
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 70),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Emergency Fund:',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Rp999.000.000.000',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),

                      // **Row untuk Notifikasi, Mata (Visibility), dan Link**
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50), // Lebih turun
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Notifikasi
                            Container(
                              width: 100,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.notifications, size: 46),
                            ),

                            // **Mata (Visibility)**
                            Container(
                              width: 100,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.visibility, size: 46),
                            ),

                            // Link
                            Container(
                              width: 100,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.link, size: 46),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // **Navigasi Bawah**
              Container(
                margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFE13D56),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // **History**
                    const Icon(
                      Icons.history,
                      color: Colors.black,
                      size: 30,
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
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    // **Profile**
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
            ],
          ),
        ],
      ),
    );
  }
}
