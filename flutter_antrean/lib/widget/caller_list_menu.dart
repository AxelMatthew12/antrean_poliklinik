import 'package:flutter/material.dart';

// Menu tab untuk halaman caller (Menunggu, Berjalan, Selesai)
class CallerListMenu extends StatelessWidget {
  final String activeTab; // Tab yang sedang aktif
  final ValueChanged<String> onTabChanged; // Callback saat tab diganti

  const CallerListMenu({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab "Menunggu"
            _TabItem(
              title: "Menunggu",
              isActive: activeTab == "Menunggu",
              onTap: () => onTabChanged("Menunggu"),
            ),

            const SizedBox(width: 15),

            // Tab "Berjalan"
            _TabItem(
              title: "Dilayani",
              isActive: activeTab == "Dilayani",
              onTap: () => onTabChanged("Dilayani"),
            ),

            const SizedBox(width: 15),

            // Tab "Selesai"
            _TabItem(
              title: "Selesai",
              isActive: activeTab == "Selesai",
              onTap: () => onTabChanged("Selesai"),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk tiap item tab
class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Tangani tap
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF256EFF) : Colors.white,
          border: isActive
              ? Border.all(color: const Color(0xFF256EFF), width: 1)
              : Border.all(color: const Color(0xFF256EFF), width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : const Color(0xFF256EFF), // Teks putih jika aktif
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
