import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'next_page.dart';
import 'saving.dart';
import '../target-screen/target_screen.dart';
import '../auth-screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = doc['username'];
      });
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

          // Konten utama
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 55),
              Text(
                'Hey, $username!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25
                ),
              ),
              const SizedBox(height: 25),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Saving(),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/icons/wallet-pinned.png',
                  width: 51,
                  height: 51,
                ),
              ),

              // Box Current Saving
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Box Current Saving
                  Container(
                    width: 374,
                    height: 220,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECFEFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Current Saving for',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF342E37),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.86,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '(Target Name) :',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF342E37),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.86,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp999.000.000.000',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF342E37),
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp999.000.000.000',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9D8DF1),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lingkaran di bawah
                  Positioned(
                    bottom: -35,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NextPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE13D56),
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 7,
                              color: const Color(0xFFECFEFD),
                            ),
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
                          child: Image.asset(
                            'assets/icons/plus.png', // path icon plus kamu
                            width: 30,
                            height: 30,
                            color: Colors.white, // Optional: kasih warna putih supaya kelihatan
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Emergency Fund Box
              Container(
                width: 374,
                height: 133,
                decoration: ShapeDecoration(
                    color: const Color(0xFFECFEFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ]),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Emergency Fund:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp999.000.000.000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Row ikon bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    height: 96,
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
                        ]),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/notification.png',
                        width: 46,
                        height: 46,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 96,
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
                        ]),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/eye.png',
                        width: 54,
                        height: 54,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 96,
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
                        ]),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/link.png',
                        width: 63,
                        height: 63,
                      ),
                    ),
                  ),
                ],
              ),

              // Navigasi bawah
              Container(
                margin: const EdgeInsets.only(
                    bottom: 10, left: 20, right: 20, top: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFE13D56),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/icons/arrow.png',
                      width: 33,
                      height: 33,
                      color: const Color(0xFF342E37),
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
            ],
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