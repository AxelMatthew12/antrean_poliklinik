import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DeleteAccountService {
  // ============================================================
  // 🔵 Popup Konfirmasi
  // ============================================================
  Future<void> showDeleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Hapus Akun",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF256EFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Anda yakin ingin melakukan hapus akun?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    // ❌ TIDAK
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Tidak",
                            style: TextStyle(
                              color: Color(0xFF256EFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ✅ Ya Hapus
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // tutup popup
                            await _deleteAccount(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF256EFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Ya, Hapus",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔵 Delete Account SAFE VERSION
  // ============================================================
  Future<void> _deleteAccount(BuildContext context) async {
    // SIMPAN context awal → agar tidak error setelah dispose
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) return;

      final uid = user.uid;

      // Hapus data user di realtime database
      final pasienRef = FirebaseDatabase.instance.ref("pasien");
      final snapshot = await pasienRef.get();

      for (var child in snapshot.children) {
        if (child.child("uid").value == uid) {
          await child.ref.remove();
          break;
        }
      }

      // Hapus antrean user
      await FirebaseDatabase.instance.ref("antrean_user/$uid").remove();

      // Hapus akun dari Firebase Auth
      await user.delete();

      // Tampilkan SnackBar (gunakan scaffold yang AMAN)
      scaffold.showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dihapus."),
          backgroundColor: Colors.green,
        ),
      );

      // Arahkan user ke welcome_page
      Future.delayed(const Duration(milliseconds: 700), () {
        navigator.pushNamedAndRemoveUntil(
          "/welcome",
          (route) => false,
        );
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus akun: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
