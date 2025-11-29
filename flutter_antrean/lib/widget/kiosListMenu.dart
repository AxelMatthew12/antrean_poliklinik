import 'package:flutter/material.dart';

class KiosListMenu extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const KiosListMenu({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TabItem(
            title: "List Poli",
            isActive: activeTab == "List Poli",
            onTap: () => onTabChanged("List Poli"),
          ),
          _TabItem(
            title: "Antrean",
            isActive: activeTab == "Antrean",
            onTap: () => onTabChanged("Antrean"),
          ),
          _TabItem(
            title: "Riwayat",
            isActive: activeTab == "Riwayat",
            onTap: () => onTabChanged("Riwayat"),
          ),
        ],
      ),
    );
  }
}

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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF256EFF) : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: const Color(0xFF256EFF),
            width: 1.8,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF256EFF),
          ),
        ),
      ),
    );
  }
}
