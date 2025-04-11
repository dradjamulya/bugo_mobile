import 'package:bugo_mobile/screens/home-screen/home_screen.dart';
import 'package:flutter/material.dart';
import '../auth-screen/profile_screen.dart';
import 'input_screen.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({Key? key}) : super(key: key);

  @override
  _TargetScreenState createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  List<bool> isStarred = List.generate(7, (index) => false); // Menyimpan status bintang

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCFDF7), // Background cyan
      body: Stack(
        children: [
          // Header Gambar
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
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Chip(
                            backgroundColor: Color(0xFF342E37), // Hitam
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
                          color: Color(0xFFFFED66), // Kuning
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFFE13D56)
                          ),
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const InputScreen()
                              ),
                            );
                          },
                        )
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
                          color: const Color(0xFFFFFFFF), // Putih
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          title: const Text(
                            'Mobil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF342E37), // Hitam
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Rp999.000.000 ', // Jumlah yang sudah ditabung
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF342E37), // Hitam
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/ Rp999.000.000', // Target tabungan
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9D8DF1), // Ungu
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Completion Plan : 2027',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isStarred[index] ? Icons.star : Icons.star_border,
                              color: isStarred[index] ? Colors.yellow : Colors.black,
                              size: 35, // Ukuran lebih fit
                            ),
                            onPressed: () {
                              setState(() {
                                isStarred[index] = !isStarred[index];
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Navigasi Bawah
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFE13D56), // Pink
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
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
                      // Tetap di halaman yang sama tanpa reload
                    },
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.black, // Indikasi sedang aktif
                      size: 30,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
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
