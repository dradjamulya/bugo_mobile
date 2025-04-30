import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import '/services/auth_service.dart';


class ErrorRegisterScreen extends StatefulWidget {
  const ErrorRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ErrorRegisterScreen> createState() => _ErrorRegisterScreenState();
}

class _ErrorRegisterScreenState extends State<ErrorRegisterScreen> {
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

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 220),
                    Text(
                      "Make sure you filled them correctly!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE13D56),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildInputField("NAME", nameController),
                    const SizedBox(height: 24),
                    buildInputField("EMAIL", emailController),
                    const SizedBox(height: 24),
                    buildInputField("USERNAME", usernameController),
                    const SizedBox(height: 24),
                    buildInputField("PASSWORD", passwordController, isPassword: true),
                    const SizedBox(height: 24),
                    buildInputField("CONFIRM PASSWORD", confirmPasswordController, isPassword: true),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account, Bud? ",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF9D8DF1),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFED66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final username = usernameController.text.trim();
                        final password = passwordController.text.trim();
                        final confirmPassword = confirmPasswordController.text.trim();

                        if (password != confirmPassword) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ErrorRegisterScreen(),
                            ),
                          );
                          return;
                        }

                        final msg = await authService.registerWithEmail(
                          email,
                          password,
                          username,
                          name,
                        );

                        if (msg == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration Succeed')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }
                      },
                      child: Text(
                        'REGISTER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadows: [
          const BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xFF342E37),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
