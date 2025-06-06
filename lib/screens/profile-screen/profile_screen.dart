import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editprofile_popup.dart';

class UserProfile {
  final String uid;
  final String username;
  final String name;
  final String email;

  UserProfile({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
  });

  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final prefix = parts[0].isNotEmpty ? '${parts[0][0]}***' : '***';
    return '$prefix@${parts[1]}';
  }
}

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserProfile> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User data not found');
    }
    return UserProfile(
      uid: user.uid,
      username: doc.data()?['username'] ?? 'No Username',
      name: doc.data()?['name'] ?? 'No Name',
      email: doc.data()?['email'] ?? 'No Email',
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<UserProfile> _userProfileFuture;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _userProfileFuture = _profileService.fetchUserData();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showEditPopup(UserProfile userProfile) {
    _usernameController.text = userProfile.username;
    _nameController.text = userProfile.name;
    _emailController.text = userProfile.email;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Profile Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return EditProfilePopup(
          usernameController: _usernameController,
          nameController: _nameController,
          emailController: _emailController,
          onProfileSaved: _loadData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCFDF7),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('User profile not found.'));
          }

          final userProfile = snapshot.data!;
          return Stack(
            children: [
              Container(color: const Color(0xFFBCFDF7)),
              _buildTopCurveBackground(),
              SafeArea(
                child: _buildMainContent(userProfile),
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
            child: Container(height: 280.h, color: const Color(0xFFE13D56)),
          ),
          Expanded(child: Container(color: const Color(0xFFBCFDF7))),
        ],
      ),
    );
  }

  Widget _buildMainContent(UserProfile userProfile) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Text(
          'Hey, ${userProfile.username}!',
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 15.h),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildInfoField(hint: userProfile.username, label: 'Username'),
                SizedBox(height: 20.h),
                _buildInfoField(hint: userProfile.name, label: 'Name'),
                SizedBox(height: 20.h),
                _buildInfoField(hint: userProfile.maskedEmail, label: 'Email'),
                SizedBox(height: 20.h),
                _buildInfoField(
                    hint: '********', label: 'Password', isObscured: true),
                SizedBox(height: 40.h),
                _buildEditButton(() => _showEditPopup(userProfile)),
                const Spacer(flex: 3),
                
                SizedBox(height: 20.h), 
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(
      {required String hint, required String label, bool isObscured = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFD),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF342E37),
        ),
      ),
    );
  }

  Widget _buildEditButton(VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFED66),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
      ),
      onPressed: onPressed,
      child: Text(
        'EDIT PROFILE',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF342E37),
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
