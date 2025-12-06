import 'package:antrean_poliklinik/features/caller/models/antrean_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CallerDetailAntrean extends StatelessWidget {
  final AntreanModel antrean;

  const CallerDetailAntrean({super.key, required this.antrean});

  /// ================== GET DATA PASIEN ==================
  Future<Map<String, dynamic>?> getPatient() async {
    final ref = FirebaseDatabase.instance.ref("pasien");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map dataMap = snapshot.value as Map;
      for (final key in dataMap.keys) {
        final pasienData = Map<String, dynamic>.from(dataMap[key]);
        if (pasienData['uid'] == antrean.pasienUID) {
          return pasienData;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2B6BFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Detail Antrean",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryBlue,
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: getPatient(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pasien = snapshot.data;
          final nama = pasien?['nama'] ?? "Tidak ada nama";
          final telepon = pasien?['no_hp'] ?? "Tidak ada telepon";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// ================= LOGO + NOMOR ANTREAN (SEJAJAR) =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/klik_antri.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    const Spacer(),

                    Text(
                      antrean.nomor,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// PROFILE ICON
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE0E7FF),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color.fromARGB(255, 64, 100, 220),
                  ),
                ),

                const SizedBox(height: 20),

                /// ===== NAMA PASIEN =====
                _pillBox(text: "Pasien: $nama", fontSize: 18),

                const SizedBox(height: 12),

                /// ===== TELEPON + POLI =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pillBox(text: telepon, fontSize: 16),
                    const SizedBox(width: 10),
                    _pillBox(text: antrean.layananID, fontSize: 16),
                  ],
                ),

                const SizedBox(height: 25),

                /// ===== DETAIL ANTREAN =====
                _outlineCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleBlue("Detail Waktu Antrean"),
                      const SizedBox(height: 14),
                      _rowBlue(
                        "Waktu Ambil",
                        antrean.waktu_ambil,
                        fontSize: 16,
                      ),
                      _rowBlue(
                        "Waktu Ambil",
                        antrean.waktu_panggil,
                        fontSize: 16,
                      ),
                      _rowBlue(
                        "Waktu Ambil",
                        antrean.waktu_selesai,
                        fontSize: 16,
                      ),
                      _rowBlue("Status", antrean.status, fontSize: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Tutup Riwayat",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===================== CUSTOM UI COMPONENT ======================

  Widget _pillBox({required String text, double fontSize = 15}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF2B6BFF), width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF2B6BFF),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _outlineCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF2B6BFF), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _titleBlue(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2B6BFF),
      ),
    );
  }

  Widget _rowBlue(String label, String value, {double fontSize = 15}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: Color(0xFF2B6BFF)),
          children: [
            TextSpan(text: "$label : "),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
