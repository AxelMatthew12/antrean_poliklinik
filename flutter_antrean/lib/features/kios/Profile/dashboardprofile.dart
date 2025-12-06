import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:antrean_poliklinik/features/kios/Settings/logout.dart';
import 'package:antrean_poliklinik/features/kios/Profile/detailProfile.dart';
import 'package:antrean_poliklinik/features/kios/Settings/SettingProfile.dart';
import 'package:antrean_poliklinik/features/kios/Profile/ContactUs.dart';

class DashboardProfile extends StatefulWidget {
  final Map? userData;

  /// Optional callback that allows the parent widget (e.g., HomePage)
  /// to refresh its header data when the profile is updated.
  final VoidCallback? onUpdate;

  const DashboardProfile({
    super.key,
    this.userData,
    this.onUpdate,
  });

  @override
  State<DashboardProfile> createState() => _DashboardProfileState();
}

class _DashboardProfileState extends State<DashboardProfile> {
  late Map userData;
  final db = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    /// Initialize local user data from the passed widget data.
    userData = Map.from(widget.userData ?? {});
  }

  /// Reloads the latest user data from Firebase
  /// and updates both this widget and the parent widget if needed.
  Future<void> _reloadUserData() async {
    final uid = auth.currentUser!.uid;
    final pasienRef = db.child("pasien");

    final snapshot = await pasienRef.get();

    for (var child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map);

      if (data["uid"] == uid) {
        setState(() {
          userData = data;
        });

        /// Notify the parent widget to refresh UI
        widget.onUpdate?.call();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (userData['nama'] ?? "").toString();
    final avatarChar = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          children: [
            // ---------------------------------------------------------
            // Title section
            // ---------------------------------------------------------
            Stack(
              alignment: Alignment.center,
              children: const [
                Center(
                  child: Text(
                    "Profil Saya",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF256EFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Opacity(
                    opacity: 0,
                    child: Icon(Icons.arrow_back_ios, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ---------------------------------------------------------
            // Profile avatar and name display
            // ---------------------------------------------------------
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
                    backgroundColor: Colors.blue.shade400,
                    child: Text(
                      avatarChar,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name.isEmpty ? "John Doe" : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ---------------------------------------------------------
            // Menu list
            // ---------------------------------------------------------
            _menuItem(
              Icons.person_outline,
              "Profil",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailProfile(userData: userData),
                  ),
                );

                /// Refresh user data after returning from detail page
                await _reloadUserData();
              },
            ),

            _menuItem(
              Icons.settings,
              "Pengaturan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingProfile()),
                );
              },
            ),

            _menuItem(
              Icons.help_outline,
              "Bantuan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsPage()),
                );
              },
            ),

            _menuItem(
              Icons.logout,
              "Keluar",
              onTap: () => LogoutDialog.show(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Menu item builder for profile actions
  // ---------------------------------------------------------
  Widget _menuItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
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
                // Icon container
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

                // Title text
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

                // Navigation arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
