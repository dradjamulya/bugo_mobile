import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'screens/target-screen/target_screen.dart';
import 'widgets/bottom_nav_bar.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double baseWidth = 390;
  late double scale;
  late Size screenSize;

  String username = '';
  Map<String, dynamic>? favoriteTarget;
  int totalEmergencyFund = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    fetchUsername();
    fetchFavoriteTarget();
    fetchTotalEmergencyFund();
  }

  Future<void> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() => username = doc['username']);
    }
  }

  Future<void> fetchFavoriteTarget() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final targetQuery = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .where('is_favorite', isEqualTo: true)
        .limit(1)
        .get();

    if (targetQuery.docs.isNotEmpty) {
      final data = targetQuery.docs.first.data();
      final targetId = targetQuery.docs.first.id;

      final savings = await FirebaseFirestore.instance
          .collection('savings')
          .where('user_id', isEqualTo: uid)
          .where('target_id', isEqualTo: targetId)
          .get();

      final expenses = await FirebaseFirestore.instance
          .collection('expenses')
          .where('user_id', isEqualTo: uid)
          .where('target_id', isEqualTo: targetId)
          .get();

      final totalSaved = savings.docs
          .fold(0, (sum, doc) => sum + (doc['amount'] as int? ?? 0));
      final totalExpenses = expenses.docs
          .fold(0, (sum, doc) => sum + (doc['amount'] as int? ?? 0));

      setState(() {
        favoriteTarget = {
          'name': data['target_name'],
          'saved': totalSaved - totalExpenses,
          'total': data['target_amount'],
        };
      });
    }
  }

  Future<void> fetchTotalEmergencyFund() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final targets = await FirebaseFirestore.instance
        .collection('targets')
        .where('user_id', isEqualTo: uid)
        .get();

    final total = targets.docs
        .fold(0, (sum, doc) => sum + (doc['emergency_fund'] as int? ?? 0));
    setState(() => totalEmergencyFund = total);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    scale = screenSize.width / baseWidth;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFBCFDF7)),
          _buildTopCurveBackground(),
          SafeArea(child: _buildMainContent()),
        ],
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
              height: 300 * scale,
              color: const Color(0xFFE13D56),
            ),
          ),
          Expanded(child: Container(color: const Color(0xFFBCFDF7))),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
            child: Column(
              children: [
                SizedBox(height: screenSize.height * 0.08),
                Text(
                  'Hey, $username!',
                  style: GoogleFonts.poppins(
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.07),
                Image.asset('assets/icons/wallet-pinned.png',
                    width: 51, height: 51),
                SizedBox(height: screenSize.height * 0.03),
                _buildFavoriteTargetCard(),
                SizedBox(height: screenSize.height * 0.06),
                _buildEmergencyFundCard(),
                SizedBox(height: screenSize.height * 0.04),
                _buildQuickAccessIcons(),
                SizedBox(height: screenSize.height * 0.04),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 30, right: 30),
          child: BottomNavBar(activePage: 'home'),
        ),
      ],
    );
  }

  Widget _buildFavoriteTargetCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 195 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFECFEFD),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Center(
            child: favoriteTarget == null
                ? Text('No Favorite Target',
                    style: GoogleFonts.poppins(fontSize: 16 * scale))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Current Saving for',
                          style: GoogleFonts.poppins(fontSize: 14 * scale)),
                      Text('${favoriteTarget!['name']} :',
                          style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 8 * scale),
                      Text(
                        'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget!['saved'])}',
                        style: GoogleFonts.poppins(
                            fontSize: 30 * scale, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Rp${NumberFormat("#,###", "id_ID").format(favoriteTarget!['total'])}',
                        style: GoogleFonts.poppins(
                            fontSize: 20 * scale,
                            color: const Color(0xFF9D8DF1)),
                      ),
                    ],
                  ),
          ),
        ),
        Positioned(
          bottom: -35,
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TargetScreen()));
              fetchFavoriteTarget();
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE13D56),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFECFEFD), width: 7),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Image.asset('assets/icons/plus.png',
                    width: 30, height: 30, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyFundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFD),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text('Emergency Fund:',
              style: GoogleFonts.poppins(fontSize: 14 * scale)),
          SizedBox(height: 4 * scale),
          Text(
            'Rp${NumberFormat("#,###", "id_ID").format(totalEmergencyFund)}',
            style: GoogleFonts.poppins(
                fontSize: 28 * scale, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconBox('assets/icons/notification.png', 46),
        _iconBox('assets/icons/eye.png', 54),
        _iconBox('assets/icons/link.png', 63),
      ],
    );
  }

  Widget _iconBox(String path, double size) {
    return Container(
      width: 100 * scale,
      height: 96 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFD),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Image.asset(path, width: size, height: size),
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
