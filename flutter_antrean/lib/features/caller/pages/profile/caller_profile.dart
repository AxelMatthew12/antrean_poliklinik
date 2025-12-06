import 'package:antrean_poliklinik/features/kios/Settings/logout.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== TITLE ======
            const Center(
              child: Text(
                "Profil Petugas",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF256EFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ====== FOTO PROFIL ======
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE0E7FF),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF4064DC),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ====== MENU LIST ======
            _menuItem(icon: Icons.person_outline, title: "Nama", value: nama),

            FutureBuilder<String?>(
              future: getLoketNama(loketID),
              builder: (context, snapshot) {
                final loketNama = snapshot.data ?? "Tidak ada loket";
                return _menuItem(
                  icon: Icons.storefront,
                  title: "Loket",
                  value: loketNama,
                );
              },
            ),

            _menuItem(icon: Icons.email_outlined, title: "Email", value: email),

            _menuItem(
              icon: Icons.logout,
              title: "Keluar",
              isAction: true,
              onTap: () {
                LogoutDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //  🔹 MENU ITEM — PAKAI BORDER RADIUS 50 + BACKGROUND BIRU
  // ======================================================
  Widget _menuItem({
    required IconData icon,
    required String title,
    String? value,
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF256EFF).withOpacity(0.10),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON
              Icon(icon, color: const Color(0xFF256EFF), size: 30),

              const SizedBox(width: 20),

              // TEXTS
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (value != null)
                      Text(
                        value!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              // // ARROW ICON
              // Icon(
              //   Icons.arrow_forward_ios,
              //   size: 18,
              //   color: isAction ? Colors.redAccent : Colors.black45,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
