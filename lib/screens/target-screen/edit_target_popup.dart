import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';

class EditTargetPopup extends StatefulWidget {
  final String targetId;
  final String initialName;
  final String initialAmount;
  final String initialDeadline;
  final VoidCallback onTargetUpdated;

  const EditTargetPopup({
    super.key,
    required this.targetId,
    required this.initialName,
    required this.initialAmount,
    required this.initialDeadline,
    required this.onTargetUpdated,
  });

  @override
  State<EditTargetPopup> createState() => _EditTargetPopupState();
}

class _EditTargetPopupState extends State<EditTargetPopup> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final deadlineController = TextEditingController();

  double targetMonthlyIncome = 0;
  double targetMonthlyExpenses = 0;
  double targetDependentsCost = 0;
  double targetMonthlyEmergencyFundGoal = 0;
  double targetTotalDebt = 0;
  String? selectedRiskLevel;

  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    amountController.text = widget.initialAmount;
    deadlineController.text = widget.initialDeadline;
    _loadTargetData();
  }

  Future<void> _loadTargetData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingData = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('targets')
          .doc(widget.targetId)
          .get();

      if (mounted && docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          // Menggunakan nama field yang BENAR sesuai InputTargetScreen
          targetMonthlyIncome = (data['monthly_income'] ?? 0).toDouble();
          targetMonthlyExpenses = (data['monthly_expenses'] ?? 0).toDouble();
          targetDependentsCost = (data['dependents_cost'] ?? 0).toDouble();
          targetMonthlyEmergencyFundGoal = (data['emergency_fund'] ?? 0).toDouble();
          targetTotalDebt = (data['total_debt'] ?? 0).toDouble();
          selectedRiskLevel = data['risk_level'] as String? ?? 'moderate'; // Default ke moderate

          nameController.text = data['target_name'] as String? ?? widget.initialName;
          // Pastikan amount dari Firestore (yang merupakan int) dikonversi ke String untuk controller
          amountController.text = (data['target_amount'] ?? int.tryParse(widget.initialAmount) ?? 0).toString();
          deadlineController.text = data['target_deadline'] as String? ?? widget.initialDeadline;
        });
      } else if (mounted) {
         print("Target document with ID ${widget.targetId} not found!");
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Target document (ID: ${widget.targetId}) not found.')),
        );
      }
    } catch (e) {
      print("Error loading target data for ID ${widget.targetId}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load target data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _updateTarget() async {
    if (nameController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        deadlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    // parseRupiah dari InputTargetScreenStep1
    int parseRupiah(String value) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    final amount = parseRupiah(amountController.text); // Gunakan parseRupiah jika controller masih mengandung "Rp"
    final deadlineText = deadlineController.text.trim();

    if (amount == 0) { // parseRupiah akan menghasilkan 0 jika gagal atau string kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Amount must be a valid number greater than 0.')),
      );
      return;
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(deadlineText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid deadline format. Use dd/MM/yyyy.')),
      );
      return;
    }

    try {
      // Data yang diupdate ke Firestore
      Map<String, dynamic> updatedData = {
        'target_name': nameController.text.trim(),
        'target_amount': amount,
        'target_deadline': deadlineText,
        // Jika field konteks finansial dan risk level bisa diedit di page 1,
        // Anda harus mengambilnya dari controller masing-masing di page 1
        // dan menyimpannya di sini. Saat ini, page 1 tidak punya input untuk itu.
        // Contoh:
        // 'monthly_income': parseRupiah(controllerUntukIncomeDiPage1.text),
        // 'risk_level': selectedRiskLevel, // Jika ada UI untuk mengubah risk_level di popup ini
      };


      await FirebaseFirestore.instance
          .collection('targets')
          .doc(widget.targetId)
          .update(updatedData);

      widget.onTargetUpdated();

      if (mounted) {
        await _loadTargetData(); // Reload data setelah update
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target updated successfully!')),
        );
      }
    } catch (e) {
      print('Failed to update target: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update target: $e')),
        );
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
          const SnackBar(content: Text('Target deleted successfully!')),
        );
      }
    } catch (e) {
      print('Failed to delete target: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete target: $e')),
        );
      }
    }
  }

  Widget _buildEditPage(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Edit Target', scale),
        _buildLabel('Target Name', scale),
        _buildTextField(nameController, scale),
        _buildLabel('Amount', scale),
        _buildTextField(amountController, scale,
            keyboardType: TextInputType.number), // Sebaiknya gunakan input formatter Rupiah juga di sini
        _buildLabel('Deadline (dd/MM/yyyy)', scale),
        _buildTextField(deadlineController, scale,
            keyboardType: TextInputType.datetime),
        SizedBox(height: 30 * scale),
        Center(child: _buildSaveButton('SAVE EDIT', scale, _updateTarget)),
        SizedBox(height: 10 * scale),
        Center(
          child: GestureDetector(
            onTap: _deleteTarget,
            child: Text(
              'Delete Target',
              style: GoogleFonts.poppins(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE13D56),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _min(double a, double b) => a < b ? a : b;

  Widget _buildRecommendationPage(double scale) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (_isLoadingData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 10 * scale),
            Text("Loading Saving Plan...",
                style: GoogleFonts.poppins(fontSize: 14 * scale)),
          ],
        ),
      );
    }
    if (selectedRiskLevel == null) {
         return Center(
           child: Text("Risk level for this target is not set.", style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.orangeAccent)),
         );
    }
    
    // Ambil amount dari controller, yang sudah diisi dengan data dari Firestore.
    // parseRupiah jika controller mungkin masih mengandung format "Rp"
    int parseRupiah(String value) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    final double targetAmount = parseRupiah(amountController.text).toDouble();
    final String deadlineString = deadlineController.text.trim();

    int targetDeadlineInMonths = 0;
    if (deadlineString.isNotEmpty) {
      try {
        final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        final DateTime deadlineDate = inputFormat.parseStrict(deadlineString);
        final DateTime nowDate = DateTime.now();

        if (deadlineDate.isAfter(nowDate)) {
          int yearDiff = deadlineDate.year - nowDate.year;
          int monthDiff = deadlineDate.month - nowDate.month;
          targetDeadlineInMonths = (yearDiff * 12) + monthDiff;

          if (targetDeadlineInMonths <= 0) {
             if (deadlineDate.year > nowDate.year ||
                (deadlineDate.year == nowDate.year && deadlineDate.month > nowDate.month) ||
                (deadlineDate.year == nowDate.year && deadlineDate.month == nowDate.month && deadlineDate.day > nowDate.day)) {
                targetDeadlineInMonths = 1;
             } else {
                targetDeadlineInMonths = 0;
             }
          }
        } else {
          targetDeadlineInMonths = 0;
        }
      } catch (e) {
        print("Error parsing deadline date in recommendation: $e");
        targetDeadlineInMonths = 0;
      }
    }

    if (targetAmount <= 0 || targetDeadlineInMonths <= 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0 * scale),
          child: Text(
            "Target amount must be greater than 0 and the deadline must be a future date to generate a plan. Current months to deadline: $targetDeadlineInMonths.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 14 * scale, color: Colors.redAccent),
          ),
        ),
      );
    }

    double sisaPendapatan = targetMonthlyIncome - (targetMonthlyExpenses + targetDependentsCost);
    sisaPendapatan = max(0, sisaPendapatan);

    double debtFundPerMonthAllocation = 0;
    if (targetTotalDebt > 0 && targetDeadlineInMonths > 0) {
      debtFundPerMonthAllocation = targetTotalDebt / targetDeadlineInMonths;
    }
    debtFundPerMonthAllocation = max(0, debtFundPerMonthAllocation);

    double idealSavingForPrimaryTarget = targetAmount / targetDeadlineInMonths;

    double riskMultiplier;
    String riskTitle;
    switch (selectedRiskLevel) {
      case 'conservative': // Menyesuaikan dengan nilai dari InputTargetScreenStep2
        riskMultiplier = 0.70;
        riskTitle = 'Low Risk Plan (Konservatif, Aman, Stabil - 70%)';
        break;
      case 'aggressive': // Menyesuaikan dengan nilai dari InputTargetScreenStep2
        riskMultiplier = 0.90;
        riskTitle = 'High Risk Plan (Agresif, Target Tercapai Cepat - 90%)';
        break;
      case 'moderate': // Menyesuaikan dengan nilai dari InputTargetScreenStep2
      default:
        riskMultiplier = 0.80;
        riskTitle = 'Medium Risk Plan (Seimbang, Tidak Terlalu Aman atau Agresif - 80%)';
        selectedRiskLevel = 'moderate';
        break;
    }

    double totalSavingsForTarget = _min(
        idealSavingForPrimaryTarget, riskMultiplier * sisaPendapatan);
    totalSavingsForTarget = max(0, totalSavingsForTarget);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Your Saving Plan', scale),
          _info('Target Name : ', nameController.text.trim(), scale),
          _info('Target Amount : ', formatter.format(targetAmount), scale),
          _info('Deadline : ', deadlineController.text.trim(), scale),
          _info('Months to Deadline : ', '$targetDeadlineInMonths months', scale),
          Divider(height: 24 * scale, thickness: 1 * scale),
          _info(riskTitle, null, scale),
          SizedBox(height: 12 * scale),
          _info('  Total Savings per Month:', null, scale),
          _value('  ${formatter.format(totalSavingsForTarget)} / Month', scale),
          _orText(scale),
          _value('  ${formatter.format(totalSavingsForTarget * 12)} / Year', scale,
              isAlt: true),
          SizedBox(height: 12 * scale),
          _info('  Emergency Fund per Month:', null, scale),
          _value(
              '  ${formatter.format(targetMonthlyEmergencyFundGoal)} / Month', scale),
          _orText(scale),
          _value('  ${formatter.format(targetMonthlyEmergencyFundGoal * 12)} / Year',
              scale,
              isAlt: true),
          SizedBox(height: 12 * scale),
          if (debtFundPerMonthAllocation > 0) ...[
            _info('  Debt Fund per Month:', null, scale),
            _value('  ${formatter.format(debtFundPerMonthAllocation)} / Month',
                scale),
            _orText(scale),
            _value(
                '  ${formatter.format(debtFundPerMonthAllocation * 12)} / Year',
                scale,
                isAlt: true),
            SizedBox(height: 12 * scale),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360 * scale,
          height: currentPage == 1 ? 700 * scale : 557 * scale,
          padding: EdgeInsets.symmetric(
              horizontal: 24 * scale, vertical: 20 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (!mounted) return;
                    setState(() => currentPage = index);
                  },
                  children: [
                    _buildEditPage(scale),
                    _buildRecommendationPage(scale),
                  ],
                ),
              ),
              SizedBox(height: 12 * scale),
              _buildStepIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return SizedBox(
      width: 18,
      height: 7,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 7,
              height: 7,
              decoration: ShapeDecoration(
                color: currentPage == 0
                    ? const Color(0xFF808080)
                    : const Color(0xFFD9D9D9),
                shape: const OvalBorder(),
              ),
            ),
          ),
          Positioned(
            left: 11,
            child: Container(
              width: 7,
              height: 7,
              decoration: ShapeDecoration(
                color: currentPage == 1
                    ? const Color(0xFF808080)
                    : const Color(0xFFD9D9D9),
                shape: const OvalBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * scale),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF342E37),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 14 * scale),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF342E37),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, double scale,
      {TextInputType? keyboardType}) {
    return Container(
      margin: EdgeInsets.only(top: 6 * scale),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      height: 44 * scale,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCDCDCD)),
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFF808080)],
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14 * scale),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildSaveButton(
      String label, double scale, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFFFFED66),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF342E37),
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? value, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 8 * scale),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: label,
                style: GoogleFonts.poppins(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFAB2C3F))),
            if (value != null)
              TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF342E37))),
          ],
        ),
      ),
    );
  }

  Widget _value(String text, double scale, {bool isAlt = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 2 * scale),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: isAlt ? const Color(0xFF7A6EBB) : const Color(0xFF342E37),
        ),
      ),
    );
  }

  Widget _orText(double scale) => Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * scale),
        child: Text(
          'or',
          style: GoogleFonts.poppins(
              fontSize: 12 * scale, color: const Color(0xFF342E37)),
        ),
      );
}