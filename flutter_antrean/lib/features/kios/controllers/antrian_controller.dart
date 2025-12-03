import 'package:firebase_database/firebase_database.dart';

class AntrianController {
  final db = FirebaseDatabase.instance.ref();

  /// Panggil antrean berikutnya untuk poli yang diberikan.
  /// - Mengubah status antrean yang dipanggil menjadi "berjalan"
  /// - Mengupdate node display/{poliId} dengan informasi current & next
  Future<void> panggilAntrian(String poliId) async {
    try {
      final antrianRef = db.child("antrian").child(poliId);

      // 1. Ambil seluruh anak di node antrian/{poliId}
      final snap = await antrianRef.get();
      if (!snap.exists) {
        print("Tidak ada antrian untuk $poliId");
        return;
      }

      // 2. Kumpulkan entry dengan key dan data (aman dari null & tipe)
      final entries = <Map<String, dynamic>>[];
      int idx = 0;
      for (final child in snap.children) {
        final key = child.key;
        final raw = child.value;
        if (key == null) continue;

        // Pastikan data berbentuk Map<String, dynamic>
        final Map<String, dynamic> data;
        if (raw is Map) {
          // safe cast
          data = Map<String, dynamic>.from(raw);
        } else {
          // kalau value bukan Map (jarang) -> buat map minimal
          data = {"nomor": key, "status": "menunggu"};
        }

        // Coba dapatkan nilai numerik untuk sorting (prioritaskan field "nomor" jika ada)
        int? sortValue;
        final nomorField = data["nomor"];
        if (nomorField != null) {
          // nomor mungkin "001" atau "10" atau "A001"
          final nomorStr = nomorField.toString();
          // hapus non-digit di awal jika ada huruf (misal "A001" -> "001")
          final digits = nomorStr.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isNotEmpty) {
            sortValue = int.tryParse(digits);
          }
        }
        // fallback jika tidak bisa parse -> gunakan urutan masuk
        sortValue ??= idx;

        entries.add({
          "key": key,
          "data": data,
          "sort": sortValue,
        });
        idx++;
      }

      if (entries.isEmpty) {
        print("Tidak ada entri valid di antrian/$poliId");
        return;
      }

      // 3. Sort berdasarkan sortValue (ascending)
      entries.sort((a, b) => (a["sort"] as int).compareTo(b["sort"] as int));

      // 4. Cari first entry yang status != "selesai"
      Map<String, dynamic>? currentEntry;
      int currentIndex = -1;
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        final data = e["data"] as Map<String, dynamic>;
        final status = (data["status"] ?? "menunggu").toString().toLowerCase();
        if (status != "selesai") {
          currentEntry = e;
          currentIndex = i;
          break;
        }
      }

      if (currentEntry == null) {
        print("Semua antrian telah selesai untuk $poliId");
        return;
      }

      final currentKey = currentEntry["key"] as String;
      final currentData = currentEntry["data"] as Map<String, dynamic>;
      final currentNomor = (currentData["nomor"] ?? currentKey).toString();

      // 5. Update status antrean yang dipanggil -> "berjalan"
      await antrianRef.child(currentKey).update({
        "status": "berjalan",
        "waktu_panggil": DateTime.now().toIso8601String(),
      });

      // 6. Tentukan next (jika ada)
      String nextNomor = "-";
      if (currentIndex + 1 < entries.length) {
        final nextData = entries[currentIndex + 1]["data"] as Map<String, dynamic>;
        nextNomor = (nextData["nomor"] ?? entries[currentIndex + 1]["key"]).toString();
      }

      // 7. Update node display untuk dibaca display website
      await db.child("display").child(poliId).update({
        "current": currentNomor,
        "next": nextNomor,
        "status": "dipanggil",
        "timestamp": ServerValue.timestamp,
      });

      print("Berhasil memanggil: $currentNomor (key:$currentKey) pada $poliId");
    } catch (e, st) {
      print("Error panggilAntrian: $e");
      print(st);
    }
  }
}
