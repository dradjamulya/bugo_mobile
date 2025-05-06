import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth-screen/profile_screen.dart';
import '../home-screen/home_screen.dart';
import '../target-screen/input_target_screen_step2.dart';

class InputTargetScreenStep1 extends StatefulWidget {
  const InputTargetScreenStep1({super.key});

  @override
  State<InputTargetScreenStep1> createState() => _InputTargetScreenStep1State();
}

class _InputTargetScreenStep1State extends State<InputTargetScreenStep1> {
  final TextEditingController targetNameController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController targetDeadlineController = TextEditingController();
  final TextEditingController monthlyIncomeController = TextEditingController();
  final TextEditingController monthlyExpensesController = TextEditingController();
  final TextEditingController dependentsCostController = TextEditingController();
  final TextEditingController emergencyFundController = TextEditingController();
  final TextEditingController totalDebtController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? selectedDeadline;

  int parseRupiah(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDeadline) {
      setState(() {
        selectedDeadline = picked;
        targetDeadlineController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> saveTargetData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final targetName = targetNameController.text.trim();
    final targetAmount = parseRupiah(targetAmountController.text);
    final targetDeadline = targetDeadlineController.text.trim();

    if (targetName.isEmpty || targetAmount == 0 || targetDeadline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    await _firestore.collection('targets').add({
      'user_id': user.uid,
      'target_name': targetName,
      'target_amount': targetAmount,
      'target_deadline': targetDeadline,
      'monthly_income': parseRupiah(monthlyIncomeController.text),
      'monthly_expenses': parseRupiah(monthlyExpensesController.text),
      'dependents_cost': parseRupiah(dependentsCostController.text),
      'emergency_fund': parseRupiah(emergencyFundController.text),
      'total_debt': parseRupiah(totalDebtController.text),
      'created_at': FieldValue.serverTimestamp(),
      'is_favorite': false,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InputTargetScreenStep2()),
    );
  }

  Widget inputField(String hint, TextEditingController controller,
      {bool isRupiah = false, bool isDate = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: const Color(0xFFECFEFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        keyboardType: TextInputType.number,
        inputFormatters: isRupiah
            ? [
                MoneyInputFormatter(
                  leadingSymbol: 'Rp',
                  thousandSeparator: ThousandSeparator.Period,
                )
              ]
            : [],
        onTap: isDate ? () => selectDate(context) : null,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xFF342E37),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
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
                    child: Container(
                      height: 250,
                      color: const Color(0xFFE13D56),
                    ),
                  ),
                  Expanded(child: Container(color: const Color(0xFFBCFDF7))),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 140),
                    inputField('Target Name (Car, House, Etc)', targetNameController),
                    const SizedBox(height: 25),
                    inputField('Target Amount (Rp)', targetAmountController, isRupiah: true),
                    const SizedBox(height: 25),
                    inputField('Target Deadline (dd/MM/yyyy)', targetDeadlineController, isDate: true),
                    const SizedBox(height: 25),
                    inputField('Monthly Income', monthlyIncomeController, isRupiah: true),
                    const SizedBox(height: 25),
                    inputField('Personal Monthly Expenses', monthlyExpensesController, isRupiah: true),
                    const SizedBox(height: 25),
                    inputField('Dependents Cost', dependentsCostController, isRupiah: true),
                    const SizedBox(height: 25),
                    inputField('Monthly Emergency Fund Goal', emergencyFundController, isRupiah: true),
                    const SizedBox(height: 25),
                    inputField('Total Debt', totalDebtController, isRupiah: true),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: saveTargetData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFED66),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 72),
                  ],
                ),
              ),
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
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ProfileScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
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
