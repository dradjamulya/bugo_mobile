import 'package:bugo_mobile/screens/target-screen/input_expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'target_screen.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _transactions;
  int totalSavings = 0;

  @override
  void initState() {
    super.initState();
    _transactions = fetchTransactions();
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final savingsSnapshot = await _firestore
        .collection('savings')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final expensesSnapshot = await _firestore
        .collection('expenses')
        .where('user_id', isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> transactions = [];

    for (var doc in savingsSnapshot.docs) {
      int amount = doc['amount'] ?? 0;
      totalSavings += amount;
      transactions.add({
        'type': 'savings',
        'amount': amount,
        'description': doc['description'] ?? "Savings",
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    for (var doc in expensesSnapshot.docs) {
      int amount = doc['amount'] ?? 0;
      totalSavings -= amount;
      transactions.add({
        'type': 'expense',
        'amount': amount,
        'description': doc['description'] ?? "Expense",
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    transactions.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(height: 400, color: const Color(0xFFE13D56)),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _transactions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No transactions found"));
              }

              final transactions = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                                          const TargetScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final rotate =
                                            Tween(begin: -pi, end: 0.0)
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
                          const SizedBox(height: 40),

                          Text(
                            'Current Saving :',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currency.format(totalSavings),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const InputExpensesScreen(),
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
                            side: const BorderSide(width: 5, color: Color(0xFFE13D56)),
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
                            'assets/icons/minus.png',
                            width: 26,
                            height: 26,
                            color: Color(0xFF342E37),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Box transaksi
                    ...transactions.map((tx) {
                      final isExpense = tx['type'] == 'expense';
                      final date = (tx['timestamp'] as Timestamp).toDate();
                      final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(date);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          width: 401,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFEFD),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx['description'] ?? "-",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF342E37),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currency.format(tx['amount']),
                                style: GoogleFonts.poppins(
                                  color: isExpense ? Color(0xFFB20000) : Color(0xFF342E37),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formattedDate,
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
                      );
                    }).toList(),
                  ],
                ),
              );
            },
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
