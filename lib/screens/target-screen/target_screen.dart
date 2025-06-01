import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'balance_screen.dart';
import 'input_screen.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'edit_target_popup.dart'; 

class TargetScreen extends StatefulWidget {
  const TargetScreen({Key? key}) : super(key: key);

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>> _targetData;

  @override
  void initState() {
    super.initState();
    _targetData = fetchData();
  }

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

    final expensesSnapshot = await _firestore
        .collection('expenses')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final validTargetIds = targetsSnapshot.docs.map((doc) => doc.id).toSet();

    Map<String, int> savingsPerTarget = {};
    Map<String, int> expensesPerTarget = {};
    int totalTargetAmount = 0;

    for (var doc in savingsSnapshot.docs) {
      String targetId = doc['target_id'];
      if (!validTargetIds.contains(targetId)) continue;
      int amount = doc['amount'] ?? 0;
      savingsPerTarget[targetId] = (savingsPerTarget[targetId] ?? 0) + amount;
    }

    for (var doc in expensesSnapshot.docs) {
      String targetId = doc['target_id'];
      if (!validTargetIds.contains(targetId)) continue;
      int amount = doc['amount'] ?? 0;
      expensesPerTarget[targetId] = (expensesPerTarget[targetId] ?? 0) + amount;
    }

    List<Map<String, dynamic>> targets = [];
    int totalSavings = 0;

    for (var doc in targetsSnapshot.docs) {
      final data = doc.data();
      final targetId = doc.id;
      final int targetAmount = data['target_amount'] is int
          ? data['target_amount']
          : int.tryParse(data['target_amount'].toString()) ?? 0;

      final int saved = (savingsPerTarget[targetId] ?? 0) - (expensesPerTarget[targetId] ?? 0);
      final int validSaved = saved < 0 ? 0 : saved;

      totalTargetAmount += targetAmount;
      totalSavings += validSaved;

      targets.add({
        'id': targetId,
        'target_name': data['target_name'],
        'target_amount': targetAmount,
        'target_deadline': data['target_deadline'],
        'saved_amount': validSaved,
        'is_favorite': data['is_favorite'] ?? false,
      });
    }

    return {
      'total_savings': totalSavings,
      'total_target': totalTargetAmount,
      'targets': targets,
    };
  }

  Future<void> toggleFavorite(String targetId, bool isFav) async {
    await _firestore.collection('targets').doc(targetId).update({
      'is_favorite': !isFav,
    });

    final updatedData = await fetchData();
    setState(() {
      _targetData = Future.value(updatedData);
    });
  }

  Future<void> refreshTargets() async {
    setState(() {
      _targetData = fetchData();
    });
  }

  void showEditTargetPopup(Map<String, dynamic> target) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit Target',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => EditTargetPopup(
      targetId: target['id'],
      initialName: target['target_name'],
      initialAmount: target['target_amount'].toString(),
      initialDeadline: target['target_deadline'],
      onTargetUpdated: refreshTargets,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 390;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(height: 400 * scale, color: const Color(0xFFE13D56)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30 * scale, left: 20 * scale, right: 20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildFlipButton(scale),
                      SizedBox(height: 12 * scale),
                      Center(child: buildTargetStats(scale)),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _targetData,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final targets = snapshot.data!['targets'] as List;
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 20 * scale),
                        itemCount: targets.length,
                        itemBuilder: (context, index) =>
                            GestureDetector(
                              onTap: () => showEditTargetPopup(targets[index]),
                              child: buildTargetCard(targets[index], scale),
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 34,
            left: 30,
            right: 30,
            child: BottomNavBar(activePage: 'target'),
          ),
        ],
      ),
    );
  }

  Widget buildFlipButton(double scale) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const BalanceScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final rotate = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              builder: (_, __) {
                final isUnder = rotate.value < pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotate.value),
                  child: isUnder ? child : Container(color: Colors.transparent),
                );
              },
            );
          },
        ),
      ),
      child: Container(
        width: 63 * scale,
        height: 33 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF342E37),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
        ),
        child: Center(
          child: Text('Flip',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget buildTargetStats(double scale) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _targetData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
        final totalSavings = snapshot.data!['total_savings'] as int;
        final totalTarget = snapshot.data!['total_target'] as int;

        return Column(
          children: [
            Text('Current Target:',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale, fontWeight: FontWeight.w700)),
            SizedBox(height: 15 * scale),
            Text(currency.format(totalSavings),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 34 * scale, fontWeight: FontWeight.w700)),
            SizedBox(height: 12 * scale),
            Text(currency.format(totalTarget),
                style: GoogleFonts.poppins(color: const Color(0xFFFFED66), fontSize: 22 * scale, fontWeight: FontWeight.w400)),
            SizedBox(height: 65 * scale),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen())),
              child: Container(
                width: 72 * scale,
                height: 38 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 5 * scale, color: const Color(0xFFE13D56)),
                  boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
                ),
                child: Center(
                  child: Image.asset('assets/icons/plus.png', width: 26 * scale, height: 26 * scale, color: const Color(0xFF342E37)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTargetCard(Map<String, dynamic> target, double scale) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isFavorite = target['is_favorite'] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 20 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFECFEFD),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(target['target_name'], style: GoogleFonts.poppins(fontSize: 16 * scale, color: const Color(0xFF342E37))),
                SizedBox(height: 4 * scale),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: '${currency.format(target['saved_amount'])}\n',
                          style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: const Color(0xFF342E37))),
                      TextSpan(
                          text: '/ ${currency.format(target['target_amount'])}',
                          style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: const Color(0xFF9D8DF1))),
                    ],
                  ),
                ),
                SizedBox(height: 5 * scale),
                Text('Completion Plan : ${target['target_deadline']}',
                    style: GoogleFonts.poppins(fontSize: 12 * scale, fontStyle: FontStyle.italic, color: const Color(0xFF342E37))),
              ],
            ),
          ),
          Positioned(
            right: 20 * scale,
            top: 31 * scale,
            child: GestureDetector(
              onTap: () => toggleFavorite(target['id'], isFavorite),
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                size: 67 * scale,
                color: isFavorite ? const Color(0xFFFFED66) : Colors.grey,
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
    path.arcToPoint(Offset(size.width, size.height - curveHeight),
        radius: Radius.elliptical(size.width, curveHeight * 2), clockwise: false);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
