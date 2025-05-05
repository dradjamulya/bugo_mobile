import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'input_savings_target_screen.dart';
import 'input_target_screen_step1.dart';
import '../home-screen/home_screen.dart';
import '../auth-screen/profile_screen.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFBCFDF7),
          ),

          Positioned.fill(
            child: Column(
              children: [
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    height: 300,
                    color: const Color(0xFFE13D56),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFBCFDF7),
                  ),
                ),
              ],
            ),
          ),

          // Konten Utama
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 90), 
              Text (
                'Which one will you add?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.54,
                ),
              ),
              const SizedBox(height: 25), 

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      // Username Field
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFECFEFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: TextField(
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New Target',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.edit, 
                                color: Colors.black, 
                                size: 15
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputTargetScreenStep1()),
                                );
                              },
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Name Field
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFECFEFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: TextField(
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF342E37),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add Savings',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.edit, 
                                color: Colors.black, 
                                size: 15
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputSavingsScreen()),
                                );
                              },
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 224),

                      // **Copyright**
                      Text(
                        'Copyright© BUGO2025',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF342E37),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),  
                      ),
                      const SizedBox(height: 50), // Jarak agar tidak menempel ke navigasi
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Navigasi Bawah
          Positioned(
            bottom: 10, 
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFE13D56),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/wallet.png',
                      width: 33,
                      height: 33,
                    ),
                  ),          
                  Image.asset(
                    'assets/icons/wallet.png',
                    width: 35,
                    height: 35,
                    color: const Color(0xFF342E37),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/person.png',
                      width: 35,
                      height: 35,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableIcon extends StatefulWidget {
  const EditableIcon({super.key});

  @override
  _EditableIconState createState() => _EditableIconState();
}

class _EditableIconState extends State<EditableIcon> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isEditing = !isEditing; // Toggle antara ikon edit dan centang
        });
      },
      child: CircleAvatar(
        radius: 5,
        backgroundColor: isEditing ? Colors.black : Colors.transparent,
        child: Icon(
          isEditing ? Icons.check : Icons.edit,
          color: isEditing ? Colors.white : Colors.black,
          size: 15,
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
      size.width / 2,
      size.height - 185,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}