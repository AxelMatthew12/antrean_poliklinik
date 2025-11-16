import 'package:antrean_poliklinik/core/antrean_service.dart';

final antreanService = AntreanService();

class CallerController {
  // MEMANGGIL NOMOR BERIKUTNYA
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

      print("Memanggil antrean: ${result['nomor']}");
    } catch (e) {
      print("Error saat memanggil antrean: $e");
    }
  }

  // AMBIL ANTREAN YANG SEDANG DILAYANI
  Future<String?> getSedangDilayani(String layananId) async {
    try {
      return await antreanService.getSedangDilayani(layananId);
    } catch (e) {
      print("Error getSedangDilayani: $e");
      return null;
    }
  }

  // SELESAIKAN ANTREAN
  Future<void> selesaikan(String layananId, String nomorAntrean) async {
    try {
      final success = await antreanService.selesaikanAntrean(
        layananId,
        nomorAntrean,
      );

      if (success) {
        print("Antrean $nomorAntrean telah diselesaikan.");
      }
    } catch (e) {
      print("Error saat menyelesaikan antrean: $e");
    }
  }

  // BATALKAN ANTREANa
  // BATALKAN ANTREAN
  Future<void> batalkan(String layananId, String nomorAntrean) async {
    try {
      final success = await antreanService.batalkanAntrean(
        layananId,
        nomorAntrean,
      );

      if (success) {
        print("Antrean $nomorAntrean telah dibatalkan.");
      }
    } catch (e) {
      print("Error saat membatalkan antrean: $e");
    }
  }
}
