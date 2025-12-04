import 'package:antrean_poliklinik/core/antrean_service.dart';
import 'package:firebase_database/firebase_database.dart';

final antreanService = AntreanService();

class CallerController {
  /// ===============================
  /// MEMANGGIL ANTREAN BERIKUTNYA
  /// ===============================
  Future<void> panggil(String layananId, String loketId) async {
    try {
      final result = await antreanService.panggilAntreanBerikutnya(
        layananId,
        loketId,
      );

      if (result == null) {
        print("Tidak ada antrean menunggu.");
        return;
      }

      final nomor = result['nomor'];
      final poli = result['poli'];

      print("Memanggil antrean: $nomor ($poli)");

      // TRIGGER DISPLAY + AUDIO
      await panggilAntrian(layananId, nomor, poli);

    } catch (e) {
      print("Error saat memanggil antrean: $e");
    }
  }

  /// ===============================
  /// TRIGGER DISPLAY UNTUK AUDIO
  /// ===============================
  Future<void> panggilAntrian(
      String layananID, String nomor, String namaPoli) async {
    try {
      // Update status antrean → dipanggil
      await FirebaseDatabase.instance.ref("antrean/$layananID/$nomor").update({
        "status": "dipanggil",
      });

      // Trigger display
      await FirebaseDatabase.instance.ref("display/$layananID").set({
        "nomor": nomor,
        "poli": namaPoli,
        "status": "dipanggil",
        "timestamp": ServerValue.timestamp,
      });

      print("Display triggered untuk nomor $nomor ($namaPoli)");

    } catch (e) {
      print("Error trigger display: $e");
    }
  }

  /// ===============================
  /// AMBIL ANTREAN YANG SEDANG DILAYANI
  /// ===============================
  Future<String?> getSedangDilayani(String layananId) async {
    try {
      return await antreanService.getSedangDilayani(layananId);
    } catch (e) {
      print("Error getSedangDilayani: $e");
      return null;
    }
  }

  /// ===============================
  /// SELESAIKAN ANTREAN
  /// ===============================
  Future<void> selesaikan(String layananId, String nomorAntrean) async {
    try {
      final success = await antreanService.selesaikanAntrean(
        layananId,
        nomorAntrean,
      );

      if (success) print("Antrean $nomorAntrean telah diselesaikan.");
    } catch (e) {
      print("Error saat menyelesaikan antrean: $e");
    }
  }

  /// ===============================
  /// BATALKAN ANTREAN
  /// ===============================
  Future<void> batalkan(String layananId, String nomorAntrean) async {
    try {
      final success = await antreanService.batalkanAntrean(
        layananId,
        nomorAntrean,
      );

      if (success) print("Antrean $nomorAntrean telah dibatalkan.");
    } catch (e) {
      print("Error saat membatalkan antrean: $e");
    }
  }
}
