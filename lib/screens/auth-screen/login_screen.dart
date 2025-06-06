import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';
import '../../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = "It's nice to have you back, Bud!";
  bool _hasError = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasError = true;
        _errorMessage = "Make sure you filled them correctly!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = !result['success'];
      _errorMessage = result['message'];
    });

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
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
                        SizedBox(height: 80.h),
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
                          controller: _emailController,
                          hintText: 'EMAIL',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Email cannot be empty';
                            final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!regex.hasMatch(value))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'PASSWORD',
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Password cannot be empty';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildRegisterLink(),
                        SizedBox(height: 15.h),
                        _buildLoginButton(),
                        SizedBox(height: 35.h),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFED66),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 15.h),
        minimumSize: Size(180.w, 50.h),
      ),
      onPressed: _isLoading ? null : _login,
      child: _isLoading
          ? const CircularProgressIndicator(color: Color(0xFF342E37))
          : Text('LOGIN',
              style: GoogleFonts.poppins(
                  color: const Color(0xFF342E37),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RegisterScreen(),

            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {

              const begin = Offset(1.0, 0.0); 
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
          text: "Don’t have an account, Bud? ",
          style: GoogleFonts.poppins(
              color: const Color(0xFF342E37),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Register',
              style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9D8DF1),
                  decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    required this.keyboardType,
    required this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
            ],
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword,
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.center,
            cursorColor: const Color(0xFF342E37),
            style: GoogleFonts.poppins(color: const Color(0xFF342E37), fontSize: 14.sp, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText.toUpperCase(),
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF342E37).withOpacity(0.35), fontSize: 14.sp, fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
              errorStyle: const TextStyle(height: 0.01, color: Colors.transparent),
            ),
            validator: widget.validator,
            onChanged: (value) {
              setState(() {
                _errorText = widget.validator(value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child)),
          child: _errorText != null
              ? Padding(
                  key: ValueKey(_errorText),
                  padding: EdgeInsets.only(top: 6.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(_errorText!, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFFE13D56), fontSize: 12.sp)),
                  ),
                )
              : SizedBox(key: const ValueKey('empty'), height: 6.h + 12.sp), 
        ),

        SizedBox(height: 10.h),
      ],
    );
  }
}