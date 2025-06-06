import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SavingPlan {
  final String riskTitle;
  final double totalSavingsPerMonth;
  final double emergencyFundPerMonth;
  final double debtFundPerMonth;

  SavingPlan({
    required this.riskTitle,
    required this.totalSavingsPerMonth,
    required this.emergencyFundPerMonth,
    required this.debtFundPerMonth,
  });
}

class SavingPlanCalculator {
  static int _getMonthsToDeadline(String deadlineString) {
    if (deadlineString.isEmpty) return 0;
    try {
      final deadlineDate = DateFormat('dd/MM/yyyy').parseStrict(deadlineString);
      final nowDate = DateTime.now();
      if (deadlineDate.isBefore(nowDate)) return 0;
      int yearDiff = deadlineDate.year - nowDate.year;
      int monthDiff = deadlineDate.month - nowDate.month;
      int totalMonths = (yearDiff * 12) + monthDiff;
      if (nowDate.day > deadlineDate.day && totalMonths > 0) {
        totalMonths--;
      }
      return totalMonths <= 0 ? 1 : totalMonths;
    } catch (e) {
      return 0;
    }
  }

  static SavingPlan calculate({
    required double targetAmount,
    required String deadlineString,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double dependentsCost,
    required double emergencyFundGoal,
    required double totalDebt,
    required String? riskLevel,
  }) {
    int targetDeadlineInMonths = _getMonthsToDeadline(deadlineString);
    if (targetAmount <= 0 || targetDeadlineInMonths <= 0) {
      return SavingPlan(
          riskTitle: "Invalid Data for Plan",
          totalSavingsPerMonth: 0,
          emergencyFundPerMonth: 0,
          debtFundPerMonth: 0);
    }

    double sisaPendapatan =
        max(0, monthlyIncome - (monthlyExpenses + dependentsCost));
    double debtFundPerMonthAllocation =
        max(0, totalDebt > 0 ? totalDebt / targetDeadlineInMonths : 0);
    double idealSavingForPrimaryTarget = targetAmount / targetDeadlineInMonths;

    double riskMultiplier;
    String riskTitle;
    switch (riskLevel) {
      case 'conservative':
        riskMultiplier = 0.70;
        riskTitle = 'Low Risk Plan (70%)';
        break;
      case 'aggressive':
        riskMultiplier = 0.90;
        riskTitle = 'High Risk Plan (90%)';
        break;
      default:
        riskMultiplier = 0.80;
        riskTitle = 'Medium Risk Plan (80%)';
    }

    double totalSavingsForTarget =
        min(idealSavingForPrimaryTarget, riskMultiplier * sisaPendapatan);

    return SavingPlan(
      riskTitle: riskTitle,
      totalSavingsPerMonth: max(0, totalSavingsForTarget),
      emergencyFundPerMonth: emergencyFundGoal,
      debtFundPerMonth: debtFundPerMonthAllocation,
    );
  }
}

class EditTargetPopup extends StatefulWidget {
  final String targetId;
  final VoidCallback onTargetUpdated;
  final String initialName;
  final String initialAmount;
  final String initialDeadline;

  const EditTargetPopup({
    super.key,
    required this.targetId,
    required this.onTargetUpdated,
    required this.initialName,
    required this.initialAmount,
    required this.initialDeadline,
  });

  @override
  State<EditTargetPopup> createState() => _EditTargetPopupState();
}

class _EditTargetPopupState extends State<EditTargetPopup> {
  final PageController _pageController = PageController();
  late Future<DocumentSnapshot> _targetDetailsFuture;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _deadlineController = TextEditingController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _amountController.text =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(int.tryParse(widget.initialAmount) ?? 0);
    _deadlineController.text = widget.initialDeadline;

    _targetDetailsFuture = FirebaseFirestore.instance
        .collection('targets')
        .doc(widget.targetId)
        .get();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  int _parseRupiah(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _updateTarget() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      'target_name': _nameController.text.trim(),
      'target_amount': _parseRupiah(_amountController.text),
      'target_deadline': _deadlineController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('targets')
          .doc(widget.targetId)
          .update(updatedData);
      widget.onTargetUpdated();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Target updated successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _deleteTarget() async {
    try {
      await FirebaseFirestore.instance
          .collection('targets')
          .doc(widget.targetId)
          .delete();
      widget.onTargetUpdated();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Target deleted successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: FutureBuilder<DocumentSnapshot>(
          future: _targetDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _nameController.text.isEmpty) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return _buildErrorOrNotFound();
            }

            final data = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

            return Container(
              width: 360.w,
              height: 550.h,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      children: [
                        _buildEditPage(),
                        _buildRecommendationPage(data),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildStepIndicator(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditPage() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitle('Edit Target'),
          _buildLabel('Target Name'),
          _buildTextField(_nameController),
          _buildLabel('Amount'),
          _buildTextField(_amountController,
              keyboardType: TextInputType.number),
          _buildLabel('Deadline (dd/MM/yyyy)'),
          _buildTextField(_deadlineController,
              keyboardType: TextInputType.datetime),
          const Spacer(),
          Center(child: _buildSaveButton('SAVE EDIT', _updateTarget)),
          SizedBox(height: 10.h),
          Center(child: _buildDeleteLink()),
        ],
      ),
    );
  }

  Widget _orText() => Padding(
        padding: EdgeInsets.only(left: 20.w, top: 2.h, bottom: 2.h),
        child: Text(
          'or',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: const Color(0xFF342E37),
            fontStyle: FontStyle.italic,
          ),
        ),
      );

  Widget _buildRecommendationPage(Map<String, dynamic> data) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final plan = SavingPlanCalculator.calculate(
      targetAmount: (_parseRupiah(_amountController.text)).toDouble(),
      deadlineString: _deadlineController.text,
      monthlyIncome: (data['monthly_income'] ?? 0).toDouble(),
      monthlyExpenses: (data['monthly_expenses'] ?? 0).toDouble(),
      dependentsCost: (data['dependents_cost'] ?? 0).toDouble(),
      emergencyFundGoal: (data['emergency_fund'] ?? 0).toDouble(),
      totalDebt: (data['total_debt'] ?? 0).toDouble(),
      riskLevel: data['risk_level'] as String?,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Your Saving Plan'),
        _info('Target:', _nameController.text.trim()),
        SizedBox(height: 8.h),
        _info('Amount:', _amountController.text),
        const Spacer(flex: 2),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info('Plan Type:', plan.riskTitle, isTitle: true),
              Divider(height: 24.h, thickness: 1),
              _info('Savings for Target:', null),
              _value(formatter.format(plan.totalSavingsPerMonth), '/month'),
              _orText(),
              _value(formatter.format(plan.totalSavingsPerMonth * 12), '/year',
                  isAlt: true),
              SizedBox(height: 16.h),
              _info('Emergency Fund:', null),
              _value(formatter.format(plan.emergencyFundPerMonth), '/month'),
              _orText(),
              _value(formatter.format(plan.emergencyFundPerMonth * 12), '/year',
                  isAlt: true),
              if (plan.debtFundPerMonth > 0) ...[
                SizedBox(height: 16.h),
                _info('Debt Installment:', null),
                _value(formatter.format(plan.debtFundPerMonth), '/month'),
                _orText(),
                _value(formatter.format(plan.debtFundPerMonth * 12), '/year',
                    isAlt: true),
              ]
            ],
          ),
        ),
        const Spacer(flex: 2),
        Center(
            child: _buildSaveButton(
                'OK, GOT IT!', () => Navigator.of(context).pop())),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Container(
      height: 44.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.grey.shade300)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 2.h),
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? 'This field cannot be empty'
            : null,
      ),
    );
  }

  Widget _buildTitle(String title) => Padding(
        padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
        child: Center(
            child: Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF342E37)))),
      );

  Widget _buildLabel(String text) => Padding(
        padding: EdgeInsets.only(left: 10.w, top: 10.h, bottom: 6.h),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
      );

  Widget _buildSaveButton(String label, VoidCallback onPressed) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFED66),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          elevation: 4,
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF342E37))),
      );

  Widget _buildDeleteLink() => GestureDetector(
        onTap: _deleteTarget,
        child: Text('Delete Target',
            style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFFE13D56),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFE13D56))),
      );

  Widget _buildStepIndicator() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          2,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == index ? 16.w : 8.w,
            height: 8.w,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
      );

  Widget _info(String label, String? value, {bool isTitle = false}) =>
      Text.rich(
        TextSpan(children: [
          TextSpan(
              text: '$label ',
              style: GoogleFonts.poppins(
                  fontSize: isTitle ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFAC2D40))),
          if (value != null)
            TextSpan(
                text: value,
                style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF342E37))),
        ]),
        textAlign: TextAlign.left,
      );

  Widget _value(String amount, String period, {bool isAlt = false}) {
    final valueColor =
        isAlt ? const Color(0xFF342E37) : const Color(0xFF7B6EBC);

    return Row(
      children: [
        SizedBox(width: 10.w),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        SizedBox(width: 4.w),
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            period,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: valueColor.withOpacity(0.8), // Sedikit lebih pudar
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrNotFound() => Container(
        width: 360.w,
        height: 200.h,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(50.r)),
        padding: EdgeInsets.all(20.w),
        child: const Center(
            child:
                Text("Target not found or failed to load. Please try again.")),
      );
}
