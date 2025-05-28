import 'package:bugo_mobile/screens/target-screen/target_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth-screen/profile_screen.dart';
import '../../home_screen.dart';
import 'input_target_screen_step1.dart';

class InputTargetScreenStep2 extends StatelessWidget {
  final Map<String, dynamic> targetData;

  const InputTargetScreenStep2({super.key, required this.targetData});

  Future<void> saveTargetWithRisk(BuildContext context, String riskLevel) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('targets').add({
        ...targetData,
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'is_favorite': false,
        'risk_level': riskLevel,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Target saved with $riskLevel risk level.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TargetScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save target: $e')),
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TargetScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); 
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  Widget riskOption({
    required String title,
    required String description,
    required String level,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => saveTargetWithRisk(context, level),
      child: Container(
        width: 353,
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadows: const [
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
                  text: '$title\n',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF342E37),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF342E37),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          Positioned.fill(
            child: Column(
              children: [
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    height: 320,
                    color: const Color(0xFFE13D56),
                  ),
                ),
                Expanded(child: Container(color: const Color(0xFFBCFDF7))),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder: (_, __, ___) =>
                                const InputTargetScreenStep1(),
                            transitionsBuilder: (_, animation, __, child) {
                              final tween = Tween(
                                      begin: const Offset(-1, 0),
                                      end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child);
                            },
                          ),
                        );
                      },

                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF342E37),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

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
                      const SizedBox(height: 50),
                      riskOption(
                        title: 'Conservative (Low Risk)',
                        description: 'Safe & stable savings, minimal risk.',
                        level: 'conservative',
                        context: context,
                      ),
                      riskOption(
                        title: 'Moderate (Medium Risk)',
                        description: 'Balanced approach, mix of savings & investments.',
                        level: 'moderate',
                        context: context,
                      ),
                      riskOption(
                        title: 'Aggressive (High Risk)',
                        description: 'High-growth potential, higher risk involved.',
                        level: 'aggressive',
                        context: context,
                      ),
                      const SizedBox(height: 80),
                      Text(
                        'BUGO chose these risk levels based on deep research!',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: Image.asset('assets/icons/arrow.png', width: 33, height: 33),
                  ),
                  Image.asset(
                    'assets/icons/wallet.png',
                    width: 35,
                    height: 35,
                    color: const Color(0xFF342E37),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Image.asset('assets/icons/person.png', width: 35, height: 35),
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
