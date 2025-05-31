import 'package:bugo_mobile/screens/target-screen/target_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home_screen.dart';
import '../../profile_screen.dart';

class InputSavingsScreen extends StatefulWidget {
  const InputSavingsScreen({super.key});

  @override
  State<InputSavingsScreen> createState() => _InputSavingsScreenState();
}

class _InputSavingsScreenState extends State<InputSavingsScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _selectedTargetId;
  Map<String, String> _targets = {};

  @override
  void initState() {
    super.initState();
    _fetchTargets();
  }

  Future<void> _fetchTargets() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('targets')
        .where('user_id', isEqualTo: user.uid)
        .get();

    Map<String, String> fetchedTargets = {};
    for (var doc in query.docs) {
      fetchedTargets[doc.id] = doc['target_name'];
    }

    setState(() {
      _targets = fetchedTargets;
      if (_targets.isNotEmpty) {
        _selectedTargetId = _targets.keys.first;
      }
    });
  }

  int parseRupiah(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _saveSavings() async {
    final user = _auth.currentUser;
    if (user == null || _selectedTargetId == null) return;

    final amount = parseRupiah(_amountController.text.trim());
    final description = _descriptionController.text.trim();
    if (amount == 0 || description.isEmpty) return;

    await _firestore.collection('savings').add({
      'user_id': user.uid,
      'target_id': _selectedTargetId,
      'amount': amount,
      'description': description,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Savings saved successfully")),
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(color: const Color(0xFFBCFDF7)),

            Positioned.fill(
              child: Column(
                children: [
                  ClipPath(
                    clipper: TopCurveClipper(),
                    child:
                        Container(height: 380, color: const Color(0xFFE13D56)),
                  ),
                  Expanded(child: Container(color: const Color(0xFFBCFDF7))),
                ],
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  children: [
                    const SizedBox(width: 20),
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
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Add some cash\nto your savings!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.54,
                    ),
                  ),
                ),
              ],
            ),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Input Amount
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            leadingSymbol: 'Rp',
                            useSymbolPadding: true,
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add Amount',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Input Description - Where'd you earn this?
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      child: TextField(
                        controller: _descriptionController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Where'd you earn this?",
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Dropdown Target
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedTargetId,
                          items: _targets.entries
                              .map((entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Center(
                                      child: Text(
                                        entry.value,
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTargetId = value;
                            });
                          },
                          hint: Center(
                            child: Text(
                              'Choose Target to Allocate Savings',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFED66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                      ),
                      onPressed: _saveSavings,
                      child: Text(
                        'Save',
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
            ),

            // Navigasi Bawah
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 200,
      size.width,
      size.height - 120,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
