import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home-screen/home_screen.dart';
import '../target-screen/target_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        setState(() {
          username = doc['username'];
          name = doc['name'];
          email = doc['email'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

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

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 75.5),
              Text(
                'Hey, ${username.isNotEmpty ? username : ""}!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 50),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      // Username Field
                      buildTextField(hint: username.isNotEmpty ? username : 'Username'),

                      const SizedBox(height: 28),

                      // Name Field
                      buildTextField(hint: name.isNotEmpty ? name : 'Name'),

                      const SizedBox(height: 28),

                      // Email Field
                      buildTextField(hint: email.isNotEmpty ? email : 'Email'),

                      const SizedBox(height: 28),

                      // Password Field
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFECFEFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: [
                            const BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: TextField(
                          obscureText: true,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black, size: 15),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChangePasswordScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),

                      // Copyright
                      Text(
                        'Copyright© BUGO2025',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => TargetScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/wallet.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/person.png',
                    width: 35,
                    height: 35,
                    color: const Color(0xFF342E37),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function untuk TextField yang seragam
  Widget buildTextField({required String hint}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: const Color(0xFFECFEFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadows: [
          const BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: TextField(
        style: GoogleFonts.poppins(
          color: const Color(0xFF342E37),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
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
