import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePopup extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback onProfileSaved;

  const EditProfilePopup({
    super.key,
    required this.usernameController,
    required this.nameController,
    required this.emailController,
    required this.onProfileSaved,
  });

  @override
  State<EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool isLoading = false;

  void goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void showSnackbar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red,
      ),
    );
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'username': widget.usernameController.text,
          'name': widget.nameController.text,
        });
        widget.onProfileSaved();
        Navigator.of(context).pop();
        showSnackbar("Profile updated successfully", color: Colors.green);
      }
    } catch (e) {
      showSnackbar("Failed to update profile");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updatePassword() async {
    if (newPassController.text != confirmPassController.text) {
      showSnackbar("Password confirmation does not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassController.text,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassController.text);

      Navigator.of(context).pop();
      showSnackbar("Password updated successfully", color: Colors.green);
    } catch (e) {
      showSnackbar("Failed to update password: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360 * scale,
          height: 506 * scale,
          padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => currentPage = index),
                      children: [
                        _buildProfileForm(scale),
                        _buildPasswordForm(scale),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildStepIndicator(),
                ],
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
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
                color: currentPage == 0 ? const Color(0xFF808080) : const Color(0xFFD9D9D9),
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
                color: currentPage == 1 ? const Color(0xFF808080) : const Color(0xFFD9D9D9),
                shape: const OvalBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Edit Profile', scale),
        _buildLabel('Username', scale),
        _buildTextField(widget.usernameController, scale),
        _buildLabel('Name', scale),
        _buildTextField(widget.nameController, scale),
        _buildLabel('Email', scale),
        _buildTextField(widget.emailController, scale, readOnly: true),
        SizedBox(height: 50 * scale),
        Center(
          child: _buildSaveButton(updateProfile, 'SAVE EDIT', scale),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Edit Password', scale),
        _buildLabel('Current Password', scale),
        _buildTextField(currentPassController, scale, obscure: true),
        _buildLabel('New Password', scale),
        _buildTextField(newPassController, scale, obscure: true),
        _buildLabel('Confirm New Password', scale),
        _buildTextField(confirmPassController, scale, obscure: true),
        SizedBox(height: 50 * scale),
        Center(
          child: _buildSaveButton(updatePassword, 'SAVE EDIT', scale),
        ),
      ],
    );
  }

  Widget _buildTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 4 * scale, bottom: 24 * scale),
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
      padding: EdgeInsets.only(top: 10 * scale),
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
      {bool readOnly = false, bool obscure = false}) {
    return Container(
      margin: EdgeInsets.only(top: 8 * scale),
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
        obscureText: obscure,
        readOnly: readOnly,
        style: GoogleFonts.poppins(fontSize: 14 * scale),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildSaveButton(VoidCallback onPressed, String label, double scale) {
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
}
