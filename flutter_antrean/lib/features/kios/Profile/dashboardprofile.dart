import 'package:flutter/material.dart';
import 'package:antrean_poliklinik/features/kios/Settings/logout.dart';
import 'package:antrean_poliklinik/features/kios/Profile/detailProfile.dart';
import 'package:antrean_poliklinik/features/kios/Settings/SettingProfile.dart'; 

class DashboardProfile extends StatefulWidget {
  final Map? userData;

  const DashboardProfile({super.key, this.userData});

  @override
  State<DashboardProfile> createState() => _DashboardProfileState();
}

class _DashboardProfileState extends State<DashboardProfile> {
  late Map userData;
  
  @override
  void initState() {
    super.initState();

    // copy data agar tidak null dan mudah di-update
    userData = Map.from(widget.userData ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          children: [
            // === TITLE BAR ===
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "Profil Saya",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF256EFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  child: Opacity(
                    opacity: 0,
                    child: Icon(Icons.arrow_back_ios, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // === PROFILE PHOTO + NAME ===
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE6E6E6),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: userData['foto'] != null
                        ? NetworkImage(userData['foto'])
                        : const AssetImage("assets/profile.jpeg")
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userData['nama'] ?? "John Doe",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // === MENU LIST ===
            _menuItem(
              Icons.person_outline,
              "Profil",
              onTap: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailProfile(userData: userData),
                  ),
                );

                if (updatedData != null) {
                  setState(() {
                    userData.addAll(updatedData);
                  });
                }
              },
            ),

            // === ROUTING PENGATURAN ===
            _menuItem(
              Icons.settings,
              "Pengaturan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingProfile(),
                  ),
                );
              },
            ),

            _menuItem(Icons.help_outline, "Bantuan"),

            _menuItem(
              Icons.logout,
              "Keluar",
              onTap: () {
                LogoutDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // === MENU COMPONENT ===
  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          highlightColor: Colors.black.withOpacity(0.10),
          splashColor: Colors.black.withOpacity(0.05),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF6FA8FF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF0A4EFF),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
