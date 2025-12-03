import 'package:firebase_database/firebase_database.dart';

class CallerController {
  final db = FirebaseDatabase.instance.ref();

  /// ================================
  /// 1. PANGGIL ANTREAN
  /// - Mengubah status antrean menjadi "dipanggil"
  /// - Mengirim trigger ke display agar audio berbunyi
  /// ================================
  Future<void> panggilAntrian(
    String layananID,
    String nomor,
    String namaPoli,
  ) async {
    // Update status antrean menjadi dipanggil
    await db.child("antrean/$layananID/$nomor").update({
      "status": "dilayani",
    });

    // Trigger untuk display (website)
    await db.child("display/$layananID").set({
      "nomor": nomor,
      "poli": namaPoli,
      "status": "dilayani",
      "timestamp": ServerValue.timestamp,
    });
  }

  /// ================================
  /// 2. UPDATE STATUS (fungsi umum)
  /// digunakan untuk:
  /// - Layani (menunggu → dipanggil)
  /// - Selesai (dipanggil → selesai)
  /// ================================
  Future<void> updateStatus(
      String layananID, String nomor, String status) async {
    await db.child("antrean/$layananID/$nomor").update({
      "status": status,
    });
  }

  /// ================================
  /// 3. SELESAIKAN ANTREAN
  /// ================================
  Future<void> selesaikanAntrean(String layananID, String nomor) async {
    await db.child("antrean/$layananID/$nomor").update({
      "status": "selesai",
    });
  }

  /// ================================
  /// 4. BATALKAN ANTREAN
  /// ================================
  Future<void> batalkanAntrean(String layananID, String nomor) async {
    await db.child("antrean/$layananID/$nomor").update({
      "status": "batal",
    });
  }
}
