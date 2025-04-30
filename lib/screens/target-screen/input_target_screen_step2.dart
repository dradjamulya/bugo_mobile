import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth-screen/profile_screen.dart';
import '../home-screen/home_screen.dart';

class InputTargetScreenStep2 extends StatelessWidget {
  const InputTargetScreenStep2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFBCFDF7),
          ),

          Positioned.fill(
            child: Column(
              children: [
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    height: 300,
                    color: const Color(0xFFE13D56),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFBCFDF7),
                  ),
                ),
              ],
            ),
          ),

          // Konten Utama
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 90), // Jarak atas untuk "Hey, User!"
              Center(
                child: Text(
                  'Choose your risk level!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.54,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // Conservative Field
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          width: 353,
                          height: 60,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Conservative (Low Risk)\n',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Safe & stable savings, minimal risk.',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign:
                                  TextAlign.center, // Pastikan teks di tengah
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Moderate field
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          width: 353,
                          height: 60,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Moderate (Medium Risk)\n',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Balanced approach, mix of savings & investments.',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign:
                                  TextAlign.center, // Pastikan teks di tengah
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Aggresive field
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          width: 353,
                          height: 60,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Aggressive (High Risk)\n',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'High-growth potential, higher risk involved.',
                                    style: TextStyle(
                                      color: Color(0xFF342E37),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign:
                                  TextAlign.center, // Pastikan teks di tengah
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 125),

                      // **Copyright**
                      Text(
                        'BUGO these risk level based on deep research!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                      ),
                      const SizedBox(
                          height: 50), // Jarak agar tidak menempel ke navigasi
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Navigasi Bawah
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
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/arrow.png',
                      width: 33,
                      height: 33,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/wallet.png',
                    width: 35,
                    height: 35,
                    color: const Color(0xFF342E37),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ProfileScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/person.png',
                      width: 35,
                      height: 35,
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

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 185,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
