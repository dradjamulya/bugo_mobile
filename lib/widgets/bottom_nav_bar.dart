import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor(int index) =>
        index == currentIndex ? const Color(0xFF342E37) : Colors.white;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 30.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE13D56),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            iconPath: 'assets/icons/arrow.png', //    
            index: 0,
            color: getColor(0),
          ),
          _buildNavItem(
            context: context,
            iconPath: 'assets/icons/wallet.png',
            index: 1,
            color: getColor(1),
          ),
          _buildNavItem(
            context: context,
            iconPath: 'assets/icons/person.png',
            index: 2,
            color: getColor(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required int index,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        iconPath,
        width: 35.w, 
        height: 35.w,
        color: color,
      ),
    );
  }
}