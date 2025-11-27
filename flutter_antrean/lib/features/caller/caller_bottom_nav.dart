import 'package:flutter/material.dart';

// Bottom navigation custom untuk halaman caller
class CallerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CallerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 6, right: 6, bottom: 16),
        padding: const EdgeInsets.all(6),
        width: 255,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFF256EFF), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(icon: Icons.assignment_outlined, index: 0),
            _navItem(icon: Icons.person_outline, index: 1),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 105,
        height: 55,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF256EFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(
          icon,
          size: 28,
          color: active ? Colors.white : const Color(0xFF256EFF),
        ),
      ),
    );
  }
}
