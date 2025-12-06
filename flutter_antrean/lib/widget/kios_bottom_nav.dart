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
    final double totalWidth = MediaQuery.of(context).size.width - 40;
    final double itemWidth = totalWidth / 3;

    const double containerHeight = 70;
    const double highlightSize = 48;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Highlight circle behind the active icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: (itemWidth * currentIndex) +
                  (itemWidth / 2) -
                  (highlightSize / 2),
              child: Container(
                width: highlightSize,
                height: highlightSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF256EFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Bottom navigation icons
            Row(
              children: List.generate(3, (index) {
                final IconData icon = switch (index) {
                  0 => Icons.home,
                  1 => Icons.calendar_today,
                  2 => Icons.person_outline,
                  _ => Icons.home,
                };

                final bool isActive = index == currentIndex;

                return SizedBox(
                  width: itemWidth,
                  height: containerHeight,
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 26,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF256EFF),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
