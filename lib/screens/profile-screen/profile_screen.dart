import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'editprofile_popup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double baseWidth = 390;
  late double scale;
  late Size screenSize;

  String username = '';
  String name = '';
  String email = '';
  String passwordDisplay = '********';

  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final originalEmail = doc['email'];
        final emailParts = originalEmail.split('@');
        final maskedPrefix =
            emailParts[0].isNotEmpty ? '${emailParts[0][0]}***' : '***';
        final maskedEmail = '$maskedPrefix@${emailParts[1]}';

        setState(() {
          username = doc['username'];
          name = doc['name'];
          email = maskedEmail;
          usernameController.text = doc['username'];
          nameController.text = doc['name'];
          emailController.text =
              doc['email']; // digunakan untuk backend, bukan UI
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _showEditPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Profile Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return EditProfilePopup(
          usernameController: usernameController,
          nameController: nameController,
          emailController: emailController,
          onProfileSaved: fetchUserData,
        );
      },
    );
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
          const Positioned(
            bottom: 34,
            left: 30,
            right: 30,
            child: BottomNavBar(activePage: 'profile'),
          ),
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
            child:
                Container(height: 300 * scale, color: const Color(0xFFE13D56)),
          ),
          Expanded(child: Container(color: const Color(0xFFBCFDF7))),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        SizedBox(height: screenSize.height * 0.08),
        Text('Hey, $username!',
            style: GoogleFonts.poppins(
              fontSize: 28 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
        SizedBox(height: screenSize.height * 0.08),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40 * scale),
              child: Column(
                children: [
                  SizedBox(height: 50 * scale),
                  _buildInfoField(hint: username, label: 'Username'),
                  SizedBox(height: 20 * scale),
                  _buildInfoField(hint: name, label: 'Name'),
                  SizedBox(height: 20 * scale),
                  _buildInfoField(hint: email, label: 'Email'),
                  SizedBox(height: 20 * scale),
                  _buildInfoField(
                    hint: passwordDisplay,
                    label: 'Password',
                    isObscured: true,
                  ),
                  SizedBox(height: 40 * scale),
                  _buildEditButton(),
                  SizedBox(height: 80 * scale),
                  Text('Copyright© BUGO2025',
                      style: GoogleFonts.poppins(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF342E37),
                      )),
                  SizedBox(height: 60 * scale),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInfoField({
    required String hint,
    required String label,
    bool isObscured = false,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFD),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Text(hint,
          style: GoogleFonts.poppins(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF342E37),
          )),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFED66),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding:
            EdgeInsets.symmetric(horizontal: 50 * scale, vertical: 15 * scale),
      ),
      onPressed: _showEditPopup,
      child: Text('EDIT PROFILE',
          style: GoogleFonts.poppins(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF342E37),
          )),
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
