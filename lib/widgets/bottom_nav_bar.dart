import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../screens/target-screen/target_screen.dart';
import '../screens/profile-screen/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final String activePage;

  const BottomNavBar({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    Color getColor(String page) =>
        page == activePage ? const Color(0xFF342E37) : Colors.white;

    return Container(
      width: double.infinity,
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
              if (activePage != 'home') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            child: Image.asset(
              'assets/icons/arrow.png',
              width: 33,
              height: 33,
              color: getColor('home'),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (activePage != 'target') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const TargetScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            child: Image.asset(
              'assets/icons/wallet.png',
              width: 35,
              height: 35,
              color: getColor('target'),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (activePage != 'profile') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ProfileScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            child: Image.asset(
              'assets/icons/person.png',
              width: 35,
              height: 35,
              color: getColor('profile'),
            ),
          ),
        ],
      ),
    );
  }
}
