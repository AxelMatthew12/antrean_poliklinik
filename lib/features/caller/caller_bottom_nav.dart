import 'package:flutter/material.dart';

// Bottom navigation custom untuk halaman caller
class CallerBottomNav extends StatelessWidget {
  final int currentIndex;          // Index tab yang sedang aktif
  final Function(int) onTap;       // Callback saat tab ditekan

  const CallerBottomNav ({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF256EFF),           // Warna background navbar
          borderRadius: BorderRadius.circular(30),  // Sudut membulat
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12), // Shadow halus
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomIcon(Icons.home, 0),              // Icon Home
            _bottomIcon(Icons.person_outline, 1),   // Icon Profile
          ],
        ),
      ),
    );
  }

  // Widget untuk tiap icon pada bottom nav
  Widget _bottomIcon(IconData icon, int index) {
    final bool active = index == currentIndex; // Cek apakah icon aktif

    return GestureDetector(
      onTap: () => onTap(index),                 // Tangani tap icon
      child: Icon(
        icon,
        color: active ? Colors.black : Colors.white, // Warna icon aktif/inaktif
        size: 28,
      ),
    );
  }
}
