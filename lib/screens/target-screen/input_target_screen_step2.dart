import 'package:bugo_mobile/screens/target-screen/target_screen.dart';
import 'package:flutter/material.dart';
import '../auth-screen/profile_screen.dart';
import '../home-screen/home_screen.dart';

class InputTargetScreenStep2 extends StatelessWidget {
  const InputTargetScreenStep2({super.key});

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
                  'Choose your risk level!',
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

                      // Conservative Field
                      GestureDetector(
                        onTap: () {
                          print('Conservative selected');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Conservative (Low Risk)\nSafe & stable savings, minimal risk.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: () {
                          print('Conservative selected');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Moderate (Medium Risk)\nBalanced approach, mix of savings & investments.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          print('Conservative selected');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Aggressive (High Risk)\nHigh-growth potential, higher risk involved.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),

                      // **Copyright**
                      Text(
                        'BUGO these risk level based on deep research!',
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
                      Navigator.push(context, 
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