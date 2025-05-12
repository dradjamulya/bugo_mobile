import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchTransactions();
  }

  Future<Map<String, dynamic>> fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final savingsSnapshot = await _firestore
        .collection('savings')
        .where('user_id', isEqualTo: user.uid)
        .get();

    final expensesSnapshot = await _firestore
        .collection('expenses')
        .where('user_id', isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> transactions = [];
    int totalSavings = 0;

    for (var doc in savingsSnapshot.docs) {
      int amount = doc['amount'];
      totalSavings += amount;
      transactions.add({
        'type': 'savings',
        'amount': amount,
        'description': doc['description'] ?? 'Savings',
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    for (var doc in expensesSnapshot.docs) {
      transactions.add({
        'type': 'expense',
        'amount': doc['amount'],
        'description': doc['description'] ?? 'Expense',
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    transactions.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    return {
      'total_savings': totalSavings,
      'transactions': transactions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(height: 400, color: const Color(0xFFE13D56)),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _data,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final total = snapshot.data!['total_savings'] ?? 0;
              final transactions =
                  snapshot.data!['transactions'] as List<Map<String, dynamic>>;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Center(
                      child: Text(
                        'Current Savings:',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currencyFormat.format(total),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...transactions.map((tx) {
                      final date = (tx['timestamp'] as Timestamp).toDate();
                      final formattedDate =
                          DateFormat('d MMMM yyyy', 'id_ID').format(date);
                      final isExpense = tx['type'] == 'expense';

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFEFD),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF342E37),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currencyFormat.format(tx['amount']),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isExpense ? Colors.red : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formattedDate,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF342E37),
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
