import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.person_outline, 1),
            _buildNavItem(Icons.calendar_today, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool active = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: active ? const EdgeInsets.all(10) : EdgeInsets.zero,
        decoration: active
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF256EFF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF256EFF).withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,

        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: active ? 1.06 : 1.0,
          curve: Curves.easeOut,

          child: Icon(
            icon,
            size: 28,
            color: active ? Colors.white : const Color(0xFF256EFF),
          ),
        ),
      ),
    );
  }
}
