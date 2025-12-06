import 'package:flutter/material.dart';
import 'package:antrean_poliklinik/features/kios/Settings/SettingProfile.dart';
import 'package:antrean_poliklinik/features/kios/Settings/Notification/NotificationSetting.dart';
import 'package:antrean_poliklinik/features/kios/Profile/detailProfile.dart';

class KiosHeaderWidget extends StatelessWidget {
  final Map? userData;

  const KiosHeaderWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final String nama = (userData?['nama'] ?? "User").toString();
    final String avatarLetter = nama.isNotEmpty ? nama[0].toUpperCase() : "U";

    final String? foto = userData?['foto'];
    final bool hasPhoto = foto != null && foto.toString().isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// ================= LEFT SIDE: Avatar + Name =================
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailProfile(userData: userData),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade400,

                backgroundImage:
                    hasPhoto ? NetworkImage(foto) : null,
                child: hasPhoto
                    ? null
                    : Text(
                        avatarLetter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi, WelcomeBack",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),

        /// ================= RIGHT SIDE: Notification + Settings =================
        Row(
          children: [
            _topIcon(
              Icons.notifications_none,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSetting()),
                );
              },
            ),

            const SizedBox(width: 14),

            _topIcon(
              Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingProfile()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Top Right Icon (Notif & Settings)
  Widget _topIcon(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 69, 163, 239),
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}
