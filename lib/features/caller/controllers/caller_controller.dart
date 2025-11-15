import 'package:antrean_poliklinik/core/antrean_service.dart';

final antreanService = AntreanService();

class CallerController {
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
}
