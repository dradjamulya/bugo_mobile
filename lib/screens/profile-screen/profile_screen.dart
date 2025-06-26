import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth-screen/login_screen.dart';
import 'editprofile_popup.dart';

// UserProfile Class: Represents the user data structure.
class UserProfile {
  final String uid;
  final String username;
  final String name;
  final String email;

  UserProfile(
      {required this.uid,
      required this.username,
      required this.name,
      required this.email});

  // Masks the email for privacy. e.g., "j***@example.com"
  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final prefix = parts[0].isNotEmpty ? '${parts[0][0]}***' : '***';
    return '$prefix@${parts[1]}';
  }
}

// ProfileService Class: Handles Firebase interactions for profile data and authentication.
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetches user data from Firestore.
  Future<UserProfile> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) throw Exception('User data not found');
    return UserProfile(
      uid: user.uid,
      username: doc.data()?['username'] ?? 'No Username',
      name: doc.data()?['name'] ?? 'No Name',
      email: doc.data()?['email'] ?? 'No Email',
    );
  }

  // Signs the current user out.
  Future<void> logout() async {
    await _auth.signOut();
  }
}

// ProfileScreen Widget: The main UI for the user profile.
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

  // Kicks off the data fetching process.
  void _loadData() {
    setState(() {
      _userProfileFuture = _profileService.fetchUserData();
    });
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed.
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Shows the modal popup for editing profile information.
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
      pageBuilder: (_, __, ___) => EditProfilePopup(
        usernameController: _usernameController,
        nameController: _nameController,
        emailController: _emailController,
        // Reload data after saving the profile.
        onProfileSaved: _loadData,
      ),
    );
  }

  // Handles the logout process and navigation.
  Future<void> _logout() async {
    try {
      await _profileService.logout();
      if (mounted) {
        // Navigate to LoginScreen and remove all previous routes.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show an error message if logout fails.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to log out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder handles the asynchronous loading of user data.
    return FutureBuilder<UserProfile>(
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
        // Build the main UI once data is available.
        return Stack(
          children: [
            Container(color: const Color(0xFFBCFDF7)),
            _buildTopCurveBackground(),
            SafeArea(
              bottom: false,
              child: _buildMainContent(userProfile),
            ),
          ],
        );
      },
    );
  }

  // Builds the curved background decoration at the top.
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

  // Builds the main scrollable content of the profile screen.
  Widget _buildMainContent(UserProfile userProfile) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Text('Hey, ${userProfile.username}!',
            style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
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
                _buildActionButton(
                    text: 'EDIT PROFILE',
                    onPressed: () => _showEditPopup(userProfile)),
                SizedBox(height: 20.h),
                // *** NEW WIDGET: Logout Text ***
                // This GestureDetector wraps the Text to make it tappable.
                GestureDetector(
                  onTap: _logout, // Calls the logout function when tapped.
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE13D56), // Red color for the text
                      decoration:
                          TextDecoration.underline, // Underlines the text
                      decorationColor: const Color(
                          0xFFE13D56), // Ensures underline is also red
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds a non-editable field to display user information.
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
          ]),
      alignment: Alignment.centerLeft,
      child: Text(hint,
          style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF342E37))),
    );
  }

  // Builds a styled action button (e.g., Edit Profile).
  Widget _buildActionButton(
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFED66),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
          minimumSize: Size(double.infinity, 50.h)),
      onPressed: onPressed,
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF342E37))),
    );
  }
}

// CustomClipper for creating the curved shape at the top.
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
