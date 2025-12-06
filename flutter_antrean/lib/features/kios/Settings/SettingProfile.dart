import 'package:flutter/material.dart';

// Target pages
import 'package:antrean_poliklinik/features/kios/Settings/Notification/NotificationSetting.dart';
import 'package:antrean_poliklinik/features/kios/Settings/PasswordManagement.dart';
import 'package:antrean_poliklinik/features/kios/Settings/DeleteAccount.dart';

class SettingProfile extends StatelessWidget {
  const SettingProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App header
              _buildHeader(context),
              const SizedBox(height: 40),

              // Menu items
              _menuItem(
                icon: Icons.lightbulb_outline,
                title: "Pengaturan Notifikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSetting(),
                    ),
                  );
                },
              ),
              _menuItem(
                icon: Icons.vpn_key_outlined,
                title: "Manajer Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PasswordManagement(),
                    ),
                  );
                },
              ),
              _menuItem(
                icon: Icons.person_outline,
                title: "Hapus Akun",
                onTap: () {
                  DeleteAccountService().showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the custom app bar layout
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF256EFF),
            size: 26,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Pengaturan",
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF256EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40), // Keeps title centered
      ],
    );
  }

  // Menu item component
  Widget _menuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF256EFF),
                size: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black45,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
