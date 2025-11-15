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
        return "X"; // fallback
    }
  }

  // fungsi generate nomor antrean
  Future<String> generateNomorAntrean(
    String layananId,
    String pasienUid,
  ) async {
    final prefix = getPrefix(layananId);

    final counterRef = db.child(
      "counter_antrean/$layananId",
    ); // untuk mengetahui counter antrian

    // menambahkan transaction agar antrean terlindungi dari simultaneous request untuk menghindari nomor dobel, locat atauapun ketika pasien bersama2 mengambil nomor antrean
    // Gunakan transaction agar aman dari simultaneous request
    final transactionResult = await counterRef.runTransaction((currentValue) {
      int newValue = (currentValue as int? ?? 0) + 1;
      return Transaction.success(newValue);
    });

    if (!transactionResult.committed) {
      throw Exception("Gagal update counter antrean");
    }

    final nomorUrut = (transactionResult.snapshot.value ?? 0) as int;
    final nomorAntrean = "$prefix${nomorUrut.toString().padLeft(3, '0')}";

    // Simpan data antrean
    final antreanRef = db.child("antrean/$layananId/$nomorAntrean");

    await antreanRef.set({
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

  // fungsi pemanggilan antrean
  Future<Map<String, dynamic>?> panggilAntreanBerikutnya(
    String layananId,
    String loketId,
  ) async {
    final antreanRef = db.child("antrean/$layananId");

    // Ambil antrean dengan status menunggu
    final snapshot = await antreanRef
        .orderByChild("status")
        .equalTo("menunggu")
        .limitToFirst(1)
        .get();

    if (!snapshot.exists) {
      print("Tidak ada antrean menunggu.");
      return null;
    }

    // Ambil key nomor antreannya
    final nomorAntrean = snapshot.children.first.key!;
    final data = Map<String, dynamic>.from(
      snapshot.children.first.value as Map,
    );

    // Update status jadi dilayani
    await antreanRef.child(nomorAntrean).update({
      "loket_id": loketId,
      "status": "dilayani",
      "waktu_panggil": DateTime.now().toIso8601String(),
    });

    return {"nomor": nomorAntrean, "data": data};
  }

  // selesai
  // batalkan
}
