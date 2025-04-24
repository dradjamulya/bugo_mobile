import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home-screen/home_screen.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

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
                      height: 405,
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
                  const SizedBox(height: 160),
                  Center(
                    child: Text(
                      'Change Password?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: 140),

                  // Change Field
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
                        hintText: 'CURRENT PASSWORD',
                      ),
                    ),
                  ),
                  SizedBox(height: 27),

                  // New Password Field
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
                        hintText: 'NEW PASSWORD',
                      ),
                    ),
                  ),
                  SizedBox(height: 27),

                  // Confirm new password field
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
                        hintText: 'CONFIRM NEW PASSWORD',
                      ),
                    ),
                  ),
                  SizedBox(height: 38),

                  // Save
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Text(
                      'SAVE',
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