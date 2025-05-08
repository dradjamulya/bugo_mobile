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

  late Future<List<Map<String, dynamic>>> _transactions;
  int _totalSavings = 0;

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

    int total = 0;

    for (var doc in savingsSnapshot.docs) {
      final int amount = doc['amount'];
      total += amount;
      transactions.add({
        'type': 'savings',
        'amount': amount,
        'description': doc['description'] ?? "Savings",
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    for (var doc in expensesSnapshot.docs) {
      final int amount = doc['amount'];
      total -= amount;
      transactions.add({
        'type': 'expense',
        'amount': amount,
        'description': doc['description'] ?? "Expense",
        'timestamp': doc['timestamp'] ?? Timestamp.now(),
      });
    }

    transactions.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    _totalSavings = total;

    return transactions;
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
            child: Container(height: 300, color: const Color(0xFFE13D56)),
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
                padding: const EdgeInsets.only(top: 100, bottom: 100),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 6),
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
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Current Savings',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currencyFormat.format(_totalSavings),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...transactions.map((tx) {
                      final isExpense = tx['type'] == 'expense';
                      final date = (tx['timestamp'] as Timestamp).toDate();
                      final formattedDate =
                          DateFormat('d MMMM yyyy', 'id_ID').format(date);

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
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['description'] ?? "-",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF342E37),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currencyFormat.format(tx['amount']),
                              style: GoogleFonts.poppins(
                                color:
                                    isExpense ? Colors.red : const Color(0xFF000000),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formattedDate,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF342E37),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
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