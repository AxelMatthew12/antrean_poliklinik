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
        borderRadius: BorderRadius.circular(50),
        // border: Border.all(color: const Color(0xFF256EFF), width: 2),
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
          // Animasi Highlight
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            alignment: currentIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5, // highlight mengambil setengah lebar kapsul
              child: Center(
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF256EFF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
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
    final bool active = currentIndex == index;
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
