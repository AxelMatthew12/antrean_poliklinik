import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antrean_poliklinik/features/kios/kios_antrean.dart';
import 'package:antrean_poliklinik/core/antrean_service.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';

final antreanService = AntreanService();

class DetailAntreanPage extends StatelessWidget {
  final PoliModel poli;
  final Map? userData;

  const DetailAntreanPage({super.key, required this.poli, this.userData});

  // ==========================================================
  // FUNGSI AMBIL NOMOR ANTREAN
  // ==========================================================
  Future<void> _ambilNomorAntrean(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User tidak valid. Harap login terlebih dahulu."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pasienUid = user.uid;

      // ==========================================================
      // CEK APAKAH USER SUDAH PUNYA ANTREAN AKTIF
      // ==========================================================
      final dbUser = FirebaseDatabase.instance.ref("antrean_user/$pasienUid");
      final cekUser = await dbUser.get();

      if (cekUser.exists) {
        final nomor = cekUser.child("nomor").value ?? "-";
        final poliId = cekUser.child("poli_id").value ?? "-";

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Tidak Bisa Mendaftar"),
            content: Text(
              "Anda sudah memiliki antrean aktif di:\n\n"
              "Poli : $poliId\n"
              "Nomor : $nomor\n\n"
              "Selesaikan antrean tersebut sebelum mendaftar lagi.",
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
        return;
      }

      // ==========================================================
      // USER BELUM PUNYA ANTREAN → Proses ambil nomor
      // ==========================================================
      final kiosController = KiosController();
      final nomor = await kiosController.ambilNomor(poli.id, pasienUid);

      // Simpan antrean ke node poli
      await FirebaseDatabase.instance
          .ref("antrean/${poli.id}/$nomor")
          .set({
        "layanan_id": poli.id,
        "nomor": nomor,
        "pasien_uid": pasienUid,
        "status": "menunggu",
        "waktu_ambil": DateTime.now().toIso8601String(),
      });

      // Simpan antrean user (untuk pembatasan)
      await dbUser.set({
        "poli_id": poli.id,
        "nomor": nomor,
        "status": "menunggu",
        "waktu": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nomor antrean berhasil diambil: $nomor"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error mengambil nomor antrean: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil nomor antrean."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          poli.nama,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: const AssetImage("assets/profile.jpeg"),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              poli.nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              poli.deskripsi,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 30),

            const Text(
              "Detail Layanan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),

            _detailItem(Icons.access_time, "Jam pelayanan: 07.00 - 14.00"),
            _detailItem(Icons.home_work_rounded, "Lokasi: Gedung Lantai 2"),
            _detailItem(Icons.person, "Dokter bertugas: Belum Terdata"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _ambilNomorAntrean(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Mulai Antrean",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          )
        ],
      ),
    );
  }
}
