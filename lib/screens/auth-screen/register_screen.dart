import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import '/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();

  bool _hasError = false;
  String _errorMessage = "Hi! Let's be buddies!";

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

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      Navigator.of(context).pop();
      setState(() {
        _hasError = true;
        _errorMessage = "Passwords do not match!";
      });
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
        setState(() {
          _hasError = false;
          _errorMessage = "Hi! Let's be buddies!";
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Succeed. Please Login.')),
        );
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "Make sure you filled them correctly!";
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _hasError = true;
        _errorMessage = "Unexpected error: ${e.toString()}";
      });
    }
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
                        SizedBox(height: screenHeight * 0.28),
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
                          controller: nameController,
                          hintText: "NAME",
                          isPassword: false,
                          scale: scale,
                          keyboardType: TextInputType.name,
                          validator: (value) => value == null || value.isEmpty
                              ? "Name cannot be empty"
                              : null,
                        ),
                        CustomTextField(
                          controller: emailController,
                          hintText: "EMAIL",
                          isPassword: false,
                          scale: scale,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Email cannot be empty";
                            final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!regex.hasMatch(value))
                              return "Enter a valid email";
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: usernameController,
                          hintText: "USERNAME",
                          isPassword: false,
                          scale: scale,
                          keyboardType: TextInputType.text,
                          validator: (value) => value == null || value.isEmpty
                              ? "Username cannot be empty"
                              : null,
                        ),
                        CustomTextField(
                          controller: passwordController,
                          hintText: "PASSWORD",
                          isPassword: true,
                          scale: scale,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Password cannot be empty";
                            if (value.length < 6) return "Minimum 6 characters";
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: confirmPasswordController,
                          hintText: "CONFIRM PASSWORD",
                          isPassword: true,
                          scale: scale,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) => value == null || value.isEmpty
                              ? "Please confirm your password"
                              : null,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "Already have an account, Bud? ",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF342E37),
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
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
                          onPressed: _registerUser,
                          child: Text(
                            'REGISTER',
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
