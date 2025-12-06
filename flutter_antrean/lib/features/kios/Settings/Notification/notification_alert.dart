import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationAlert {
  static StreamSubscription? _listener;

  /// 🔥 Mulai listener untuk memantau perubahan antrean realtime
  static void startListening({
    required BuildContext context,
    required bool notifEnabled,
  }) {
    // Hentikan listener lama jika ada
    _listener?.cancel();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("antrean");

    _listener = ref.onValue.listen((event) {
      if (!notifEnabled) return; // 🔇 Notifikasi dimatikan
      if (!event.snapshot.exists) return;

      for (var poliNode in event.snapshot.children) {
        for (var nomorNode in poliNode.children) {
          final data = nomorNode.value;

          if (data is Map) {
            final pasienUid = data["pasien_uid"];
            final status = data["status"];

            if (pasienUid == uid && status == "dilayani") {
              final nomor = data["nomor"] ?? "-";
              final loket = data["loket_id"] ?? "-";

              _showPopup(context, nomor.toString(), loket.toString());
            }
          }
        }
      }
    });
  }

  /// ❌ Stop listener (dipanggil saat logout atau halaman ditutup)
  static void stopListening() {
    _listener?.cancel();
  }

  /// 🔔 Pop-up notifikasi ketika antrean dipanggil
  static void _showPopup(BuildContext context, String nomor, String loket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Antrean Dipanggil!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF256EFF),
          ),
        ),
        content: Text(
          "Nomor antrean $nomor sedang dipanggil.\n"
          "Silakan menuju ke loket $loket.",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF256EFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
