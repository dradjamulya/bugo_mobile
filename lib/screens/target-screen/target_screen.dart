import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'balance_screen.dart';
import 'input_screen.dart';
import 'edit_target_popup.dart';

class TargetItem {
  final String id;
  final String name;
  final int targetAmount;
  final String deadline;
  final int savedAmount;
  final bool isFavorite;

  TargetItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.deadline,
    required this.savedAmount,
    required this.isFavorite,
  });
}

class TargetScreenData {
  final int totalSavings;
  final int totalTarget;
  final List<TargetItem> targets;

  TargetScreenData({
    required this.totalSavings,
    required this.totalTarget,
    required this.targets,
  });
}

class TargetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<TargetScreenData> fetchData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final results = await Future.wait([
      _firestore
          .collection('targets')
          .where('user_id', isEqualTo: user.uid)
          .get(),
      _firestore
          .collection('savings')
          .where('user_id', isEqualTo: user.uid)
          .get(),
      _firestore
          .collection('expenses')
          .where('user_id', isEqualTo: user.uid)
          .get(),
    ]);

    final targetsSnapshot = results[0] as QuerySnapshot;
    final savingsSnapshot = results[1] as QuerySnapshot;
    final expensesSnapshot = results[2] as QuerySnapshot;

    final validTargetIds = targetsSnapshot.docs.map((doc) => doc.id).toSet();

    final Map<String, int> savingsPerTarget = {};
    for (var doc in savingsSnapshot.docs) {
      String targetId = doc['target_id'];
      if (!validTargetIds.contains(targetId)) continue;
      savingsPerTarget[targetId] = (savingsPerTarget[targetId] ?? 0) +
          (doc['amount'] as num? ?? 0).toInt();
    }

    final Map<String, int> expensesPerTarget = {};
    for (var doc in expensesSnapshot.docs) {
      String targetId = doc['target_id'];
      if (!validTargetIds.contains(targetId)) continue;
      expensesPerTarget[targetId] = (expensesPerTarget[targetId] ?? 0) +
          (doc['amount'] as num? ?? 0).toInt();
    }

    final List<TargetItem> targets = [];
    int totalTargetAmount = 0;
    int totalSavings = 0;

    for (var doc in targetsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final targetId = doc.id;
      final int targetAmount = (data['target_amount'] as num? ?? 0).toInt();
      final int saved = (savingsPerTarget[targetId] ?? 0) -
          (expensesPerTarget[targetId] ?? 0);
      final int validSaved = saved < 0 ? 0 : saved;

      totalTargetAmount += targetAmount;
      totalSavings += validSaved;

      targets.add(TargetItem(
        id: targetId,
        name: data['target_name'] ?? 'No Name',
        targetAmount: targetAmount,
        deadline: data['target_deadline'] ?? 'No Deadline',
        savedAmount: validSaved,
        isFavorite: data['is_favorite'] ?? false,
      ));
    }

    return TargetScreenData(
      totalSavings: totalSavings,
      totalTarget: totalTargetAmount,
      targets: targets,
    );
  }

  Future<void> toggleFavorite(String targetId, bool isCurrentlyFavorite) async {
    await _firestore.collection('targets').doc(targetId).update({
      'is_favorite': !isCurrentlyFavorite,
    });
  }
}

class TargetScreen extends StatefulWidget {
  const TargetScreen({Key? key}) : super(key: key);

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final TargetService _targetService = TargetService();
  late Future<TargetScreenData> _targetDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _targetDataFuture = _targetService.fetchData();
      });
    }
  }

  Future<void> _toggleFavorite(String targetId, bool isFav) async {
    await _targetService.toggleFavorite(targetId, isFav);
    _loadData();
  }

  void _showEditTargetPopup(TargetItem target) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Target',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => EditTargetPopup(
        targetId: target.id,
        initialName: target.name,
        initialAmount: target.targetAmount.toString(),
        initialDeadline: target.deadline,
        onTargetUpdated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFBCFDF7)),
        ClipPath(
          clipper: BottomCurveClipper(),
          child: Container(height: 380.h, color: const Color(0xFFE13D56)),
        ),
        SafeArea(
          child: FutureBuilder<TargetScreenData>(
            future: _targetDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.targets.isEmpty) {
                return _buildEmptyState();
              }

              final data = snapshot.data!;
              return Column(
                children: [
                  _buildTopSection(data),
                  SizedBox(height: 9.h),
                  Expanded(
                    child: ClipRRect(
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 1.h, bottom: 10.h),
                        itemCount: data.targets.length,
                        itemBuilder: (context, index) {
                          final target = data.targets[index];
                          return GestureDetector(
                            onTap: () => _showEditTargetPopup(target),
                            child: _buildTargetCard(target),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(TargetScreenData data) {
    return Padding(
      padding: EdgeInsets.only(top: 30.h, left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlipButton(),
          SizedBox(height: 12.h),
          Center(child: _buildTargetStats(data)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Target Found',
            style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(height: 10.h),
          Text(
            'Make your first target!',
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70),
          ),
          SizedBox(height: 40.h),
          GestureDetector(
            onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InputScreen()))
                .then((_) => _loadData()),
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(width: 5.w, color: const Color(0xFFE13D56)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4))
                ],
              ),
              child: Center(
                child: Image.asset('assets/icons/plus.png',
                    width: 26.w, height: 26.w, color: const Color(0xFF342E37)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const BalanceScreen(),
        ),
      ),
      child: Container(
        width: 63.w,
        height: 33.h,
        decoration: BoxDecoration(
          color: const Color(0xFF342E37),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
          ],
        ),
        child: Center(
          child: Text('Flip',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildTargetStats(TargetScreenData data) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Column(
      children: [
        Text('Current Target:',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 13.h),
        Text(currency.format(data.totalSavings),
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 34.sp,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 12.h),
        Text(currency.format(data.totalTarget),
            style: GoogleFonts.poppins(
                color: const Color(0xFFFFED66),
                fontSize: 22.sp,
                fontWeight: FontWeight.w400)),
        SizedBox(height: 42.h),
        GestureDetector(
          onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const InputScreen()))
              .then((_) => _loadData()),
          child: Container(
            width: 72.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(width: 5.w, color: const Color(0xFFE13D56)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4))
              ],
            ),
            child: Center(
              child: Image.asset('assets/icons/plus.png',
                  width: 26.w, height: 26.w, color: const Color(0xFF342E37)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCard(TargetItem target) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFFECFEFD),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.name,
                    style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF342E37)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currency.format(target.savedAmount),
                    style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF342E37)),
                  ),
                  Text(
                    '/ ${currency.format(target.targetAmount)}',
                    style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9D8DF1)),
                  ),
                  SizedBox(height: 5.h),
                  Text('Completion Plan : ${target.deadline}',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF342E37))),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () => _toggleFavorite(target.id, target.isFavorite),
              child: Icon(
                target.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 70.r,
                color: target.isFavorite
                    ? const Color(0xFFFFED66)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
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
        radius: Radius.elliptical(size.width, curveHeight * 2),
        clockwise: false);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
