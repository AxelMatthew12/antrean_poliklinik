import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/listAppointment.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';

class DetailAntreanPage extends StatefulWidget {
  final PoliModel poli;
  final Map? userData;

  const DetailAntreanPage({super.key, required this.poli, this.userData});

  @override
  State<DetailAntreanPage> createState() => _DetailAntreanPageState();
}

class _DetailAntreanPageState extends State<DetailAntreanPage> {
  String loketId = "-"; // <-- WAJIB disimpan
  String loketNama = "-";
  String petugasNama = "-";
  String statusLoket = "-";

  @override
  void initState() {
    super.initState();
    loadRealData();
  }

  // ===============================================================
  // 🔵 FETCH DATA LOKET + PETUGAS
  // ===============================================================
  Future<void> loadRealData() async {
    final db = FirebaseDatabase.instance.ref();
    final snapshotLoket = await db.child("loket").get();

    for (var loket in snapshotLoket.children) {
      final data = loket.value as Map;

      if (data["layanan_id"] == widget.poli.id) {
        setState(() {
          loketId = loket.key ?? "-"; // <-- simpan ID loket (LKT01)
          loketNama = data["nama"] ?? "-";
          statusLoket = data["status"] ?? "-";
        });

        final petugasSnap = await db
            .child("petugas")
            .child(data["petugas_id"])
            .get();
        if (petugasSnap.exists) {
          final petugasData = petugasSnap.value as Map;
          setState(() => petugasNama = petugasData["nama"] ?? "-");
        }
        break;
      }
    }
  }

  // ===============================================================
  // 🔵 AMBIL NOMOR ANTREAN
  // ===============================================================
  Future<void> _ambilNomorAntrean(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final userRef = FirebaseDatabase.instance.ref("antrean_user/$uid");
      final cek = await userRef.get();

      // ============================================================
      // 🔵 CEK ANTREAN USER (cek status, bukan hanya exists)
      // ============================================================

      if (cek.exists) {
        final data = cek.value as Map;
        if (data["status"] != "selesai") {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Tidak Bisa Mendaftar"),
              content: const Text("Anda masih memiliki antrean aktif."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          return;
        }
      }

      // ============================================================
      // 🔵 SUDAH SELESAI → BOLEH AMBIL NOMOR BARU
      // ============================================================
      final controller = KiosController();
      final nomor = await controller.ambilNomor(widget.poli.id, uid);

      final poliId = widget.poli.id;

      // Simpan ke antrean/<poli>/<nomor>
      await FirebaseDatabase.instance.ref("antrean/$poliId/$nomor").set({
        "nomor": nomor,
        "layanan_id": poliId,
        "loket_id": loketId,
        "pasien_uid": uid,
        "status": "menunggu",
        "waktu_ambil": DateTime.now().toIso8601String(),
        "waktu_panggil": "",
        "waktu_selesai": "",
      });

      // Simpan ke antrean_user/<uid>
      await userRef.set({
        "nomor": nomor,
        "layanan_id": poliId,
        "loket_id": loketId,
        "pasien_uid": uid,
        "status": "menunggu",
        "waktu_ambil": DateTime.now().toIso8601String(),
        "waktu_panggil": "",
        "waktu_selesai": "",
      });

      // ============================================================
      // 🔵 Popup Success
      // ============================================================

      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.blue, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Anda berhasil mendaftar antrean",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Lanjut Antrean",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("ERROR: $e");
    }
  }

  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF256EFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Poli Info",
          style: TextStyle(
            color: Color(0xFF256EFF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // 🔵 BLUE HEADER CARD (Dengan gambar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF256EFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // ==== GAMBAR POLI ====
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.poli.gambar,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, stack) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.white,
                      ),
                      loadingBuilder: (context, child, loading) {
                        if (loading == null) return child;
                        return const SizedBox(
                          width: 70,
                          height: 70,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.poli.nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // DETAIL CARD
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF256EFF), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Loket"),
                  _value(loketNama),

                  const SizedBox(height: 12),
                  _label("Petugas"),
                  _value(petugasNama),

                  const SizedBox(height: 12),
                  _label("Status"),
                  _statusChip(statusLoket),

                  const SizedBox(height: 12),
                  _label("Deskripsi"),
                  Text(
                    widget.poli.deskripsi,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // BUTTON
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _ambilNomorAntrean(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF256EFF), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Ambil Antrean Poli",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF256EFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // 🔵 CUSTOM WIDGETS
  // ===============================================================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF256EFF),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _value(String text) {
    return Text(text, style: const TextStyle(fontSize: 14));
  }

  Widget _statusChip(String status) {
    final isAktif = status.toLowerCase() == "aktif";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF256EFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAktif ? Icons.check : Icons.close,
            size: 16,
            color: const Color(0xFF256EFF),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF256EFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
