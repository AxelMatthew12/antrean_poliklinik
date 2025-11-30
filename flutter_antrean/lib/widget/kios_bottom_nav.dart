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
    double width = MediaQuery.of(context).size.width - 40;
    double itemWidth = width / 3;

    double containerHeight = 70;
    double circleSize = 44;

    // posisi highlight bulat
    double topPosition = (containerHeight - circleSize) / 2;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        height: containerHeight,
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
        child: Stack(
          children: [
            // 🔵 HIGHLIGHT BULAT BIRU
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: (itemWidth - circleSize) / 2.3 + (itemWidth * currentIndex),
              top: topPosition,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF256EFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _icon(Icons.home, 0),
                _icon(Icons.person_outline, 1),
                _icon(Icons.calendar_today, 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -1.5), // ⭐ icon turun dikit agar center
            child: Icon(
              icon,
              size: 26,
              color: active ? Colors.white : const Color(0xFF256EFF),
            ),
          ),
        ),
      ),
    );
  }
}
