import 'package:antrean_poliklinik/core/antrean_service.dart';

final antreanService = AntreanService();

class KiosController {
  Future<String> ambilNomor(String layananId, String pasienUid) async {
    try {
      final nomor = await antreanService.generateNomorAntrean(
        layananId,
        pasienUid,
      );

      print("Nomor antrean: $nomor");
      return nomor;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
}
