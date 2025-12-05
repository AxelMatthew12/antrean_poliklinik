import 'package:firebase_database/firebase_database.dart';

class DisplayController {

  /// Mapping kode → POLI
  String? mapLayananKePoli(String kode) {
    switch (kode) {
      case "BO": return "UMUM";
      case "BG": return "GIGI";
      case "BA": return "ANAK";
      case "BD": return "BEDAH";
      default: return null;
    }
  }

  /// Update Display → display/POLI
  Future<void> updateDisplay({
    required String nomor,
    required String kodeLayanan,
  }) async {
    
    final poli = mapLayananKePoli(kodeLayanan);
    if (poli == null) {
      print("POLI tidak dikenali: $kodeLayanan");
      return;
    }

    try {
      await FirebaseDatabase.instance.ref("display/$poli").set({
        "nomor": nomor,
        "poli": poli,
        "status": "dipanggil",
        "timestamp": ServerValue.timestamp,
      });

      print("Display[$poli] → $nomor");

    } catch (e) {
      print("Error update display: $e");
    }
  }
}
