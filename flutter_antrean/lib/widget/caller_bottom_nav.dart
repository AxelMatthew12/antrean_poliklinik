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
    return Container(
      // tidak pakai SafeArea karena sudah ditangani di screen
      margin: const EdgeInsets.only(left: 70, right: 70, bottom: 16),
      padding: const EdgeInsets.all(6),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white, // HANYA kapsulnya yang putih
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

      child: Stack(
        children: [
          // Animasi Highlight
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            alignment: currentIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 140) / 2 - 65,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF256EFF),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          // Icons
          Row(
            children: [
              Expanded(child: _navIcon(Icons.assignment_outlined, 0)),
              Expanded(child: _navIcon(Icons.person_outline, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Center(
        child: Icon(
          icon,
          size: 26,
          color: currentIndex == index ? Colors.white : const Color(0xFF256EFF),
        ),
      ),
    );
  }
}
