import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'balance_screen.dart';
import 'input_screen.dart';
import '../home-screen/home_screen.dart';
import '../auth-screen/profile_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class TargetScreen extends StatefulWidget {
  const TargetScreen({Key? key}) : super(key: key);

  @override
  _TargetScreenState createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<Map<String, dynamic>> _targetData;

  Future<Map<String, dynamic>> fetchData() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final targetsSnapshot = await _firestore
        .collection('targets')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final savingsSnapshot = await _firestore
        .collection('savings')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final validTargetIds = targetsSnapshot.docs.map((doc) => doc.id).toSet();

    int totalSavings = 0;
    int totalTargetAmount = 0;

    Map<String, int> savingsPerTarget = {};
    List<Map<String, dynamic>> targets = [];

    for (var doc in savingsSnapshot.docs) {
      String targetId = doc['target_id'];
      if (!validTargetIds.contains(targetId)) continue;

      int amount = doc['amount'] ?? 0;
      totalSavings += amount;
      savingsPerTarget[targetId] = (savingsPerTarget[targetId] ?? 0) + amount;
    }

    for (var doc in targetsSnapshot.docs) {
      final data = doc.data();
      final targetId = doc.id;
      final int amount = (data['target_amount'] is int)
          ? data['target_amount']
          : int.tryParse(data['target_amount'].toString()) ?? 0;

      totalTargetAmount += amount ?? 0;

      targets.add({
        'id': targetId,
        'target_name': data['target_name'],
        'target_amount': amount,
        'target_deadline': data['target_deadline'],
        'saved_amount': savingsPerTarget[targetId] ?? 0,
        'is_favorite': data['is_favorite'] ?? false,
      });
    }

    return {
      'total_savings': totalSavings,
      'total_target': totalTargetAmount,
      'targets': targets,
    };
  }

  @override
  void initState() {
    super.initState();
    _targetData = fetchData();
  }

  Future<void> toggleFavorite(String targetId, bool isFav) async {
    await _firestore.collection('targets').doc(targetId).update({
      'is_favorite': !isFav,
    });
    setState(() {
      _targetData = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(height: 400, color: const Color(0xFFE13D56)),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _targetData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data found"));
              }

              final currency = NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
              final totalSavings = snapshot.data!['total_savings'] as int;
              final totalTarget = snapshot.data!['total_target'] as int;
              final targets = snapshot.data!['targets'] as List;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 800),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const BalanceScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final rotate =
                                            Tween(begin: pi, end: 0.0)
                                                .animate(animation);

                                        return AnimatedBuilder(
                                          animation: rotate,
                                          builder: (context, _) {
                                            final isUnder =
                                                rotate.value < pi / 2;

                                            return Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..setEntry(
                                                    3, 2, 0.001) 
                                                ..rotateY(rotate.value),
                                              child: isUnder
                                                  ? child
                                                  : Container(
                                                      color:
                                                          Colors.transparent),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 63,
                                  height: 33,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF342E37),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Flip',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Current Target :',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            currency.format(totalSavings),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currency.format(totalTarget),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFFED66),
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const InputScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              final tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              final offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 38,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 5, color: Color(0xFFE13D56)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/plus.png',
                            width: 26,
                            height: 26,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...targets.map((target) {
                      final isFavorite = target['is_favorite'] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 401,
                              height: 133,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFECFEFD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    target['target_name'],
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF342E37),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${currency.format(target['saved_amount'])}\n',
                                          style: const TextStyle(
                                            color: Color(0xFF342E37),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '/ ${currency.format(target['target_amount'])}',
                                          style: const TextStyle(
                                            color: Color(0xFF9D8DF1),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Completion Plan : ${target['target_deadline']}',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF342E37),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 31,
                              child: GestureDetector(
                                onTap: () {
                                  toggleFavorite(target['id'], isFavorite);
                                },
                                child: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  size: 67,
                                  color: isFavorite
                                      ? Color(0xFFFFED66)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
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
                    child: Image.asset('assets/icons/arrow.png',
                        width: 33, height: 33),
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
                    child: Image.asset('assets/icons/person.png',
                        width: 35, height: 35),
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

class BottomCurveClipper extends CustomClipper<Path> {
  final double curveHeight;

  BottomCurveClipper({this.curveHeight = 120});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveHeight);
    path.arcToPoint(
      Offset(size.width, size.height - curveHeight),
      radius: Radius.elliptical(size.width, curveHeight * 2),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
