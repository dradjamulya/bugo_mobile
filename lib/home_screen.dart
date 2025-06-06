import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'screens/target-screen/target_screen.dart';

class HomeScreenData {
  final String username;
  final Map<String, dynamic>? favoriteTarget;
  final int totalEmergencyFund;

  HomeScreenData({
    required this.username,
    this.favoriteTarget,
    required this.totalEmergencyFund,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeScreenData> _dataFuture;

  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllData();
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.youtube.com');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  Future<HomeScreenData> _fetchAllData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    final results = await Future.wait([
      _fetchUsername(uid),
      _fetchFavoriteTarget(uid),
      _fetchTotalEmergencyFund(uid),
    ]);

    return HomeScreenData(
      username: results[0] as String,
      favoriteTarget: results[1] as Map<String, dynamic>?,
      totalEmergencyFund: results[2] as int,
    );
  }

  Future<String> _fetchUsername(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc['username'] : 'User';
  }

  Future<int> _fetchTotalEmergencyFund(String uid) async {
    final targets = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .get();

    if (targets.docs.isEmpty) return 0;

    final total = targets.docs.fold<num>(0.0, (previousValue, doc) {
      final value = doc.data()['emergency_fund'] as num?;

      return previousValue + (value ?? 0);
    });

    return total.toInt();
  }

  Future<Map<String, dynamic>?> _fetchFavoriteTarget(String uid) async {
    final targetQuery = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .where('is_favorite', isEqualTo: true)
        .limit(1)
        .get();

    if (targetQuery.docs.isEmpty) return null;

    final data = targetQuery.docs.first.data();
    final targetId = targetQuery.docs.first.id;

    final savingsQuery = FirebaseFirestore.instance
        .collection('savings')
        .where('user_id', isEqualTo: uid)
        .where('target_id', isEqualTo: targetId)
        .get();

    final expensesQuery = FirebaseFirestore.instance
        .collection('expenses')
        .where('user_id', isEqualTo: uid)
        .where('target_id', isEqualTo: targetId)
        .get();

    final results = await Future.wait([savingsQuery, expensesQuery]);

    final savings = results[0] as QuerySnapshot;
    final expenses = results[1] as QuerySnapshot;

    final totalSaved =
        savings.docs.fold(0, (sum, doc) => sum + (doc['amount'] as int? ?? 0));
    final totalExpenses =
        expenses.docs.fold(0, (sum, doc) => sum + (doc['amount'] as int? ?? 0));

    return {
      'name': data['target_name'],
      'saved': totalSaved - totalExpenses,
      'total': data['target_amount'],
    };
  }

  void _refreshData() {
    if (mounted) {
      setState(() {
        _dataFuture = _fetchAllData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCFDF7),
      body: FutureBuilder<HomeScreenData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final data = snapshot.data!;
          return Stack(
            children: [
              _buildTopCurveBackground(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _buildMainContent(data),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopCurveBackground() {
    return Positioned.fill(
      child: Column(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 280.h,
              color: const Color(0xFFE13D56),
            ),
          ),
          Expanded(child: Container(color: const Color(0xFFBCFDF7))),
        ],
      ),
    );
  }

  Widget _buildMainContent(HomeScreenData data) {
    return Column(
      children: [
        const Spacer(flex: 6),
        Text(
          'Hey, ${data.username}!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const Spacer(flex: 4),
        Image.asset('assets/icons/wallet-pinned.png',
            width: 51.w, height: 51.w),
        SizedBox(height: 16.h),
        _buildFavoriteTargetCard(data.favoriteTarget),
        SizedBox(height: 55.h),
        _buildEmergencyFundCard(data.totalEmergencyFund),
        const Spacer(flex: 3),
        _buildQuickAccessIcons(),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildFavoriteTargetCard(Map<String, dynamic>? favoriteTarget) {
    final String savedAmount = _isObscured
        ? 'Rp •••••••'
        : 'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget?['saved'] ?? 0)}';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 195.h,
          decoration: BoxDecoration(
            color: const Color(0xFFECFEFD),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
            ],
          ),
          child: Center(
            child: favoriteTarget == null
                ? Text('No Favorite Target',
                    style: GoogleFonts.poppins(fontSize: 16.sp))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Current Saving for',
                          style: GoogleFonts.poppins(fontSize: 14.sp)),
                      Text('${favoriteTarget['name']} :',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8.h),
                      Text(savedAmount,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4.h),
                      Text(
                          'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget['total'])}',
                          style: GoogleFonts.poppins(
                              fontSize: 20.sp, color: const Color(0xFF9D8DF1))),
                    ],
                  ),
          ),
        ),
        Positioned(
          bottom: -35.h,
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TargetScreen()));
              _refreshData();
            },
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE13D56),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFECFEFD), width: 7.w),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4))
                ],
              ),
              child: Center(
                  child: Image.asset('assets/icons/plus.png',
                      width: 30.w, height: 30.w, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyFundCard(int totalEmergencyFund) {
    final String fundAmount = _isObscured
        ? 'Rp •••••••'
        : 'Rp${NumberFormat("#,###", "id_ID").format(totalEmergencyFund)}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFD),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text('Emergency Fund:', style: GoogleFonts.poppins(fontSize: 14.sp)),
          SizedBox(height: 4.h),
          Text(fundAmount,
              style: GoogleFonts.poppins(
                  fontSize: 28.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessIcons() {
    final String eyeIconAsset =
        _isObscured ? 'assets/icons/eye_close.png' : 'assets/icons/eye.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconBox(
          path: 'assets/icons/notification.png',
          size: 46.w,
        ),
        _iconBox(
            path: eyeIconAsset,
            size: 54.w,
            onTap: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            }),
        _iconBox(
          path: 'assets/icons/link.png',
          size: 63.w,
          onTap: _launchURL,
        ),
      ],
    );
  }

  Widget _iconBox({
    required String path,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 96.h,
        decoration: BoxDecoration(
          color: const Color(0xFFECFEFD),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: const [
            BoxShadow(
                color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
          ],
        ),
        child: Center(
          child: Image.asset(path, width: size, height: size),
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
        size.width / 2, size.height - 185, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}