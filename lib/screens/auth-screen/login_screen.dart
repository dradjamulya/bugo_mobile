import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'error_login_screen.dart';
import '../../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ErrorLoginScreen(),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ErrorLoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double responsiveMultiplier = screenWidth < 600 ? screenWidth : 600;

    return Scaffold(
      body: SizedBox(
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
                  SizedBox(height: screenHeight * 0.32),
                  Text(
                    "It's nice to have you back, Bud!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF342E37),
                      fontSize: responsiveMultiplier * 0.039,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'EMAIL',
                    isPassword: false,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    responsiveMultiplier: responsiveMultiplier,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenHeight * 0.018),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'PASSWORD',
                    isPassword: true,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    responsiveMultiplier: responsiveMultiplier,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Don’t have an account, Bud? ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: responsiveMultiplier * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: GoogleFonts.poppins(
                              fontSize: responsiveMultiplier * 0.035,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9D8DF1),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.030),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFED66),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(responsiveMultiplier * 0.085),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.18,
                          vertical: screenHeight * 0.015),
                      minimumSize:
                          Size(screenWidth * 0.045, screenHeight * 0.050),
                    ),
                    onPressed: _login,
                    child: Text(
                      'LOGIN',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
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
            blurRadius: 4,
            offset: Offset(0, 4),
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
            hintText: hintText.toUpperCase(),
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
