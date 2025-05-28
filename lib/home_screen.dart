import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'screens/target-screen/target_screen.dart';
import 'screens/auth-screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  Map<String, dynamic>? favoriteTarget;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchFavoriteTarget();
    fetchTotalEmergencyFund();
  }

  Future<void> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = doc['username'];
      });
    }
  }

  Future<void> fetchFavoriteTarget() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final targetQuery = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .where('is_favorite', isEqualTo: true)
        .limit(1)
        .get();

    if (targetQuery.docs.isNotEmpty) {
      final targetDoc = targetQuery.docs.first;
      final targetId = targetDoc.id;
      final data = targetDoc.data();

      final savingsQuery = await FirebaseFirestore.instance
          .collection('savings')
          .where('user_id', isEqualTo: uid)
          .where('target_id', isEqualTo: targetId)
          .get();

      final expensesQuery = await FirebaseFirestore.instance
          .collection('expenses')
          .where('user_id', isEqualTo: uid)
          .where('target_id', isEqualTo: targetId)
          .get();

      int totalSaved = 0;
      for (var doc in savingsQuery.docs) {
        totalSaved += (doc['amount'] as int?) ?? 0;
      }

      int totalExpenses = 0;
      for (var doc in expensesQuery.docs) {
        totalExpenses += (doc['amount'] as int?) ?? 0;
      }

      setState(() {
        favoriteTarget = {
          'name': data['target_name'],
          'saved': totalSaved - totalExpenses, // dikurangi expenses
          'total': data['target_amount'],
        };
      });
    }
  }

  int totalEmergencyFund = 0;

  Future<void> fetchTotalEmergencyFund() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final targetsQuery = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .get();

    int total = 0;
    for (var doc in targetsQuery.docs) {
      total += (doc['emergency_fund'] as int?) ?? 0;
    }

    setState(() {
      totalEmergencyFund = total;
    });
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
                  child: Container(height: 300, color: const Color(0xFFE13D56)),
                ),
                Expanded(child: Container(color: const Color(0xFFBCFDF7))),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 55),
              Text(
                'Hey, $username!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 25),

              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 345,
                    height: 195,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECFEFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadows: [
                        BoxShadow(
                          color: const Color(0x3F000000),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: favoriteTarget == null
                          ? Text(
                              'No Favorite Target',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF342E37),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Current Saving for',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF342E37),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '${favoriteTarget!['name']} :',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF342E37),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget!['saved'])}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF342E37),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget!['total'])}',
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
                  Positioned(
                    bottom: -35,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder: (_, __, ___) => const TargetScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              final tween = Tween(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child);
                            },
                          ),
                        ).then((_) {
                          fetchFavoriteTarget();
                        });
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE13D56),
                          shape: OvalBorder(
                            side: BorderSide(
                                width: 7, color: const Color(0xFFECFEFD)),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0x3F000000),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/plus.png',
                            width: 30,
                            height: 30,
                            color: Colors.white,
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
                width: 345,
                height: 133,
                decoration: ShapeDecoration(
                  color: const Color(0xFFECFEFD),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  shadows: [
                    BoxShadow(
                      color: const Color(0x3F000000),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Emergency Fund:',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp${NumberFormat("#,###", "id_ID").format(totalEmergencyFund)}',
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

              // Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  iconButtonBox('assets/icons/notification.png', 46),
                  iconButtonBox('assets/icons/eye.png', 54),
                  iconButtonBox('assets/icons/link.png', 63),
                ],
              ),

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
                    Image.asset('assets/icons/arrow.png',
                        width: 33, height: 33, color: const Color(0xFF342E37)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const TargetScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Image.asset('assets/icons/wallet.png',
                          width: 35, height: 35),
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
                      child: Image.asset('assets/icons/person.png',
                          width: 35, height: 35),
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

  Widget iconButtonBox(String path, double size) {
    return Container(
      width: 100,
      height: 96,
      decoration: ShapeDecoration(
        color: const Color(0xFFECFEFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        shadows: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(path, width: size, height: size),
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
