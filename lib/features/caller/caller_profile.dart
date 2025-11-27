import 'package:antrean_poliklinik/features/profile/logout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CallerProfilePage extends StatelessWidget {
  final String uid;
  final String nama;
  final String loketID;
  final String email;

  const CallerProfilePage({
    super.key,
    required this.uid,
    required this.nama,
    required this.loketID,
    required this.email,
  });

  /// ================== GET NAMA LOKET ==================
  Future<String?> getLoketNama(String loketID) async {
    final ref = FirebaseDatabase.instance.ref("loket/$loketID");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data['nama'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          children: [
            const Text(
              "My Profile",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // FOTO + NAMA
            Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color.fromARGB(255, 64, 100, 220),
                      ),
                    ),
                    //const CircleAvatar(
                    //radius: 50,
                    //backgroundImage: AssetImage("assets/profile.jpeg"),
                    //),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 45),

            // MENU PROFIL
            _menuItem(Icons.person_outline, "Nama", value: nama),

            // Gunakan FutureBuilder untuk ambil nama loket
            FutureBuilder<String?>(
              future: getLoketNama(loketID),
              builder: (context, snapshot) {
                final loketNama = snapshot.data ?? "Tidak ada loket";
                return _menuItem(Icons.storefront, "Loket", value: loketNama);
              },
            ),

            _menuItem(Icons.email_outlined, "Email", value: email),

            _menuItem(
              Icons.logout,
              "Logout",
              onTap: () {
                LogoutDialog.show(context); // panggil dialog logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    String? value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EDFF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  if (value != null)
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
