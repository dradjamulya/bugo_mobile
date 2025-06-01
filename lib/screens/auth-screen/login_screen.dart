import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hasError = false;
  String _errorMessage = "It's nice to have you back, Bud!";

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasError = true;
        _errorMessage = "Make sure you filled them correctly!";
      });
      return;
    }

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
      setState(() {
        _hasError = false;
        _errorMessage = "It's nice to have you back, Bud!";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      Navigator.of(context).pop();
      setState(() {
        _hasError = true;
        _errorMessage = "Make sure you filled them correctly!";
      });
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / 390;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login-screen-bg-mob-bugo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.1),
                        SizedBox(
                          height: screenHeight * 0.06,
                          child: Center(
                            child: Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: _hasError
                                    ? const Color(0xFFE13D56)
                                    : const Color(0xFF342E37),
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'EMAIL',
                          isPassword: false,
                          scale: scale,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            }
                            final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!regex.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'PASSWORD',
                          isPassword: true,
                          scale: scale,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "Don’t have an account, Bud? ",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF342E37),
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Register',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9D8DF1),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFED66),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30 * scale),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.18,
                              vertical: screenHeight * 0.016,
                            ),
                            minimumSize:
                                Size(screenWidth * 0.48, screenHeight * 0.052),
                          ),
                          onPressed: _login,
                          child: Text(
                            'LOGIN',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF342E37),
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.035),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final double scale;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isPassword,
    required this.scale,
    required this.keyboardType,
    required this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(30 * widget.scale),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword,
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.center,
            cursorColor: const Color(0xFF342E37),
            style: GoogleFonts.poppins(
              color: const Color(0xFF342E37),
              fontSize: 13 * widget.scale,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText.toUpperCase(),
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF342E37).withOpacity(0.35),
                fontSize: 13 * widget.scale,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30 * widget.scale),
                borderSide: BorderSide.none,
              ),
              errorText: null, // disable default error text
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              setState(() {
                errorText = widget.validator(value);
              });
            },
            onSaved: (value) {
              setState(() {
                errorText = widget.validator(value);
              });
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                errorText!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE13D56),
                  fontSize: 11 * widget.scale,
                ),
              ),
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}