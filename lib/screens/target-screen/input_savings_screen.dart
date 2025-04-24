import 'package:bugo_mobile/screens/target-screen/input_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Container(
              color: const Color(0xFFBCFDF7),
            ),

            Positioned.fill(
              child: Column(
                children: [
                  ClipPath(
                    clipper: TopCurveClipper(),
                    child: Container(
                      height: 250,
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

            // Login Form
            Center(
              child: Column(
                children: [
                  SizedBox(height: 170),

                  // Add amount field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECFEFD),
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
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                        color: const Color(0xFF342E37),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add Amount',
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                  // Choose target to alocate savings field
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECFEFD),
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
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF342E37),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),                      
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Choose Target to Alocate Savings',
                      ),
                    ),
                  ),
                  SizedBox(height: 400),

                  // Save
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF342E37),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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