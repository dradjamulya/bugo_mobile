import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = "Hi! Let's be buddies!";
  bool _hasError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _hasError = true;
        _errorMessage = "Passwords do not match!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = !result['success'];
      _errorMessage = result['message'];
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registration successful! Please log in.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 220.h),
                        SizedBox(
                          height: 50.h,
                          child: Center(
                            child: Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: _hasError
                                    ? const Color(0xFFE13D56)
                                    : const Color(0xFF342E37),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        CustomTextField(
                          controller: _nameController,
                          hintText: "NAME",
                          keyboardType: TextInputType.name,
                          validator: (value) => value == null || value.isEmpty
                              ? "Name cannot be empty"
                              : null,
                        ),
                        CustomTextField(
                          controller: _emailController,
                          hintText: "EMAIL",
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
                          controller: _usernameController,
                          hintText: "USERNAME",
                          keyboardType: TextInputType.text,
                          validator: (value) => value == null || value.isEmpty
                              ? "Username cannot be empty"
                              : null,
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: "PASSWORD",
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Password cannot be empty";
                            if (value.length < 6) return "Minimum 6 characters";
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: "CONFIRM PASSWORD",
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) => value == null || value.isEmpty
                              ? "Please confirm your password"
                              : null,
                        ),
                        _buildLoginLink(),
                        SizedBox(height: 15.h),
                        _buildRegisterButton(),
                        SizedBox(height: 20.h),
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

  Widget _buildRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFED66),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 15.h),
        minimumSize: Size(180.w, 50.h),
      ),
      onPressed: _isLoading ? null : _registerUser,
      child: _isLoading
          ? const CircularProgressIndicator(color: Color(0xFF342E37))
          : Text('REGISTER',
              style: GoogleFonts.poppins(
                  color: const Color(0xFF342E37),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),

            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {

              const begin = Offset(-1.0, 0.0); 
              const end =
                  Offset.zero; 
              const curve = Curves.ease; 

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child, 
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Already have an account, Bud? ",
          style: GoogleFonts.poppins(
              color: const Color(0xFF342E37),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Login',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9D8DF1),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
