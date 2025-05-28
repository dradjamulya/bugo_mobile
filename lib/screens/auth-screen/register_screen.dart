import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'error_register_screen.dart';
import 'login_screen.dart';
import '/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = AuthService();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ErrorRegisterScreen(),
        ),
      );
      return;
    }

    try {
      final msg = await authService.registerWithEmail(
        email,
        password,
        username,
        name,
      );
      Navigator.of(context).pop();
      if (!mounted) return;

      if (msg == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Registration Succeed. Please Login.')));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ErrorRegisterScreen(),
          ),
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ErrorRegisterScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("An unexpected error occurred: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double responsiveMultiplier = screenWidth < 600 ? screenWidth : 600;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/login-screen-bg-mob-bugo.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.28),
                    Text(
                      "Hi! Let's be buddies!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF342E37),
                        fontSize: responsiveMultiplier * 0.039,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.016),
                    _buildInputField("NAME", nameController,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        responsiveMultiplier: responsiveMultiplier,
                        keyboardType: TextInputType.name),
                    SizedBox(height: screenHeight * 0.013),
                    _buildInputField("EMAIL", emailController,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        responsiveMultiplier: responsiveMultiplier,
                        keyboardType: TextInputType.emailAddress),
                    SizedBox(height: screenHeight * 0.013),
                    _buildInputField("USERNAME", usernameController,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        responsiveMultiplier: responsiveMultiplier,
                        keyboardType: TextInputType.text),
                    SizedBox(height: screenHeight * 0.013),
                    _buildInputField("PASSWORD", passwordController,
                        isPassword: true,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        responsiveMultiplier: responsiveMultiplier,
                        keyboardType: TextInputType.visiblePassword),
                    SizedBox(height: screenHeight * 0.013),
                    _buildInputField(
                        "CONFIRM PASSWORD", confirmPasswordController,
                        isPassword: true,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        responsiveMultiplier: responsiveMultiplier,
                        keyboardType: TextInputType.visiblePassword),
                    SizedBox(
                        height: screenHeight *
                            0.025), // Spasi utama yang mendorong elemen bawah
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          // Ganti ke LoginScreen dan hapus RegisterScreen dari stack
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Already have an account, Bud? ",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: responsiveMultiplier * 0.031,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.poppins(
                                fontSize: responsiveMultiplier * 0.031,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9D8DF1),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.022),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFED66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              responsiveMultiplier * 0.085),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.18,
                            vertical: screenHeight * 0.016),
                        minimumSize:
                            Size(screenWidth * 0.48, screenHeight * 0.052),
                      ),
                      onPressed: _registerUser,
                      child: Text(
                        'REGISTER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: responsiveMultiplier * 0.031,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    required double screenWidth,
    required double screenHeight,
    required double responsiveMultiplier,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: screenHeight * 0.058,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.045,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveMultiplier * 0.085),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: const Color(0xFF342E37),
          style: GoogleFonts.poppins(
            color: const Color(0xFF342E37),
            fontSize: responsiveMultiplier * 0.032,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint.toUpperCase(),
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF342E37).withOpacity(0.35),
              fontSize: responsiveMultiplier * 0.032,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
