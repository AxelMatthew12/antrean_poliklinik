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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _TabItem(
            title: "List Poli",
            isActive: activeTab == "List Poli",
            onTap: () => onTabChanged("List Poli"),
          ),
          const SizedBox(width: 10),
          _TabItem(
            title: "Appointment",
            isActive: activeTab == "Appointment",
            onTap: () => onTabChanged("Appointment"),
          ),
          const SizedBox(width: 10),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : const Color(0xFFE6EDFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
