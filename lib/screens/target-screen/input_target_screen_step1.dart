import 'package:bugo_mobile/screens/target-screen/input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'input_target_screen_step2.dart';

class InputTargetScreenStep1 extends StatefulWidget {
  const InputTargetScreenStep1({super.key});

  @override
  State<InputTargetScreenStep1> createState() => _InputTargetScreenStep1State();
}

class _InputTargetScreenStep1State extends State<InputTargetScreenStep1> {
  final TextEditingController targetNameController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController targetDeadlineController =
      TextEditingController();
  final TextEditingController monthlyIncomeController = TextEditingController();
  final TextEditingController monthlyExpensesController =
      TextEditingController();
  final TextEditingController dependentsCostController =
      TextEditingController();
  final TextEditingController emergencyFundController = TextEditingController();
  final TextEditingController totalDebtController = TextEditingController();

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
    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
        targetDeadlineController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void goToStep2() {
    final targetName = targetNameController.text.trim();
    final targetAmount = parseRupiah(targetAmountController.text);
    final targetDeadline = targetDeadlineController.text.trim();

    if (targetName.isEmpty || targetAmount == 0 || targetDeadline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    final targetData = {
      'target_name': targetName,
      'target_amount': targetAmount,
      'target_deadline': targetDeadline,
      'monthly_income': parseRupiah(monthlyIncomeController.text),
      'monthly_expenses': parseRupiah(monthlyExpensesController.text),
      'dependents_cost': parseRupiah(dependentsCostController.text),
      'emergency_fund': parseRupiah(emergencyFundController.text),
      'total_debt': parseRupiah(totalDebtController.text),
    };

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) =>
            InputTargetScreenStep2(targetData: targetData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
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
          )
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        keyboardType: TextInputType.number,
        inputFormatters: isRupiah
            ? [
                CurrencyInputFormatter(
                  leadingSymbol: 'Rp',
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 0,
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
                            pageBuilder: (_, __, ___) => const InputScreen(),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        inputField('Target Name (Car, House, Etc)',
                            targetNameController),
                        const SizedBox(height: 25),
                        inputField('Target Amount (Rp)', targetAmountController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        inputField('Target Deadline (dd/MM/yyyy)',
                            targetDeadlineController,
                            isDate: true),
                        const SizedBox(height: 25),
                        inputField('Monthly Income', monthlyIncomeController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        inputField('Personal Monthly Expenses',
                            monthlyExpensesController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        inputField('Dependents Cost', dependentsCostController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        inputField('Monthly Emergency Fund Goal',
                            emergencyFundController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        inputField('Total Debt', totalDebtController,
                            isRupiah: true),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: goToStep2,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFED66),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
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
              ],
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
