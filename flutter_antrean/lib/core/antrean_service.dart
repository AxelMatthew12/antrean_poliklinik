import 'package:firebase_database/firebase_database.dart';

class AntreanService {
  final db = FirebaseDatabase.instance.ref();

  // Mapping prefix poli → nomor
  String getPrefix(String layananId) {
    switch (layananId) {
      case "POLI_UMUM":
        return "A";
      case "POLI_GIGI":
        return "B";
      default:
        return "X";
    }
  }

  // 1. Function GENERATE NOMOR ANTREAN (menunggu)
  Future<String> generateNomorAntrean(
    String layananId,
    String pasienUid,
  ) async {
    final prefix = getPrefix(layananId);

    final counterRef = db.child("counter_antrean/$layananId");

    final transactionResult = await counterRef.runTransaction((currentValue) {
      int newValue = (currentValue as int? ?? 0) + 1;
      return Transaction.success(newValue);
    });

    if (!transactionResult.committed) {
      throw Exception("Gagal update counter antrean");
    }

    final nomorUrut = (transactionResult.snapshot.value ?? 0) as int;
    final nomorAntrean = "$prefix${nomorUrut.toString().padLeft(3, '0')}";

    final antreanRef = db.child("antrean/$layananId/$nomorAntrean");

    await antreanRef.set({
      // table struktur
      "nomor": nomorAntrean,
      "pasien_uid": pasienUid,
      "layanan_id": layananId,
      "loket_id": null,
      "status": "menunggu",
      "waktu_ambil": DateTime.now().toIso8601String(),
      "waktu_panggil": null,
      "waktu_selesai": null,
    });

    return nomorAntrean;
  }

  // 2. PANGGIL ANTREAN BERIKUTNYA (menunggu → dilayani)
  Future<Map<String, dynamic>?> panggilAntreanBerikutnya(
    String layananId,
    String loketId,
  ) async {
    final antreanRef = db.child("antrean/$layananId");

    final snapshot = await antreanRef
        .orderByChild("status")
        .equalTo("menunggu")
        .limitToFirst(1)
        .get();

    if (!snapshot.exists) {
      print("Tidak ada antrean menunggu.");
      return null;
    }

    final nomorAntrean = snapshot.children.first.key!;
    final data = Map<String, dynamic>.from(
      snapshot.children.first.value as Map,
    );

    await antreanRef.child(nomorAntrean).update({
      "loket_id": loketId,
      "status": "dilayani",
      "waktu_panggil": DateTime.now().toIso8601String(),
    });

    return {"nomor": nomorAntrean, "data": data};
  }

  // 3. AMBIL ANTREAN YANG SEDANG DILAYANI
  Future<String?> getSedangDilayani(String layananId) async {
    final antreanRef = db.child("antrean/$layananId");

    final snapshot = await antreanRef
        .orderByChild("status")
        .equalTo("dilayani")
        .limitToFirst(1)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.children.first.key;
  }

  // 4. SELESAIKAN ANTREAN YANG DILAYANI
  Future<bool> selesaikanAntrean(String layananId, String nomorAntrean) async {
    final antreanRef = db.child("antrean/$layananId/$nomorAntrean");

    final snapshot = await antreanRef.get();

    if (!snapshot.exists) {
      print("Antrean tidak ditemukan");
      return false;
    }

    final data = snapshot.value as Map;
    if (data["status"] != "dilayani") {
      print("Antrean belum dipanggil, tidak bisa diselesaikan.");
      return false;
    }

    await antreanRef.update({
      "status": "selesai",
      "waktu_selesai": DateTime.now().toIso8601String(),
    });

    print("Antrean $nomorAntrean selesai.");
    return true;
  }

  // 5. BATALKAN ANTREAN (opsional untuk pasien)
  // Future<bool> batalkanAntrean(String layananId, String nomorAntrean) async {
  //   final antreanRef = db.child("antrean/$layananId/$nomorAntrean");

  //   final snapshot = await antreanRef.get();

  //   if (!snapshot.exists) {
  //     print("Antrean tidak ditemukan");
  //     return false;
  //   }

  //   await antreanRef.update({"status": "dibatalkan"});

  //   print("Antrean $nomorAntrean dibatalkan.");
  //   return true;
  // }

  Future<bool> batalkanAntrean(String layananId, String nomorAntrean) async {
    final antreanRef = db.child("antrean/$layananId/$nomorAntrean");

    final snapshot = await antreanRef.get();

    if (!snapshot.exists) {
      print("Antrean tidak ditemukan");
      return false;
    }

    final data = snapshot.value as Map;
    if (data["status"] == "selesai" || data["status"] == "dibatalkan") {
      print("Antrean sudah selesai/dibatalkan.");
      return false;
    }

    await antreanRef.update({
      "status": "dibatalkan",
      "waktu_selesai": DateTime.now().toIso8601String(),
    });

    print("Antrean $nomorAntrean dibatalkan.");
    return true;
  }
}
