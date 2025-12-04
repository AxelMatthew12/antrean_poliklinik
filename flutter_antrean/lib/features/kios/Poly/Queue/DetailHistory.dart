import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailHistoryPage extends StatefulWidget {
  final String poliId;        // poli_umum / poli_gigi / poli_anak
  final String nomorAntrean;  // A012

  const DetailHistoryPage({
    super.key,
    required this.poliId,
    required this.nomorAntrean,
  });

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  Map? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final ref = FirebaseDatabase.instance
          .ref("antrean/${widget.poliId}/${widget.nomorAntrean}");

      final snapshot = await ref.get();

      if (snapshot.exists) {
        data = snapshot.value as Map;
      }

      loading = false;
      setState(() {});
    } catch (e) {
      print("ERROR DETAIL: $e");
      loading = false;
      setState(() {});
    }
  }

  String _formatPoli(String id) {
    switch (id) {
      case "poli_umum":
        return "Poli Umum";
      case "poli_gigi":
        return "Poli Gigi";
      case "poli_anak":
        return "Poli Anak";
      default:
        return id.replaceAll("_", " ").toUpperCase();
    }
  }

  String _fmt(String? w) {
    if (w == null || w == "") return "-";
    return w.replaceAll("T", "   ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // NOMOR ANTREAN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.nomorAntrean,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF256EFF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 55, color: Colors.white),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          FirebaseAuth.instance.currentUser!.displayName ??
                              "Nama Pasien",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          FirebaseAuth.instance.currentUser!.phoneNumber ??
                              "-",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 12),

                        // POLI
                        Text(
                          _formatPoli(widget.poliId),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF256EFF),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CARD DETAIL WAKTU
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: const Color(0xFF256EFF), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  "Detail Waktu Antrean",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF256EFF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              _row("Waktu Antrean", _fmt(data!["waktu_mulai"])),
                              _row("Waktu Dilayani", _fmt(data!["waktu_dilayani"])),
                              _row("Waktu Selesai", _fmt(data!["waktu_selesai"])),
                              _row("Status", data!["status"] ?? "-"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: 200,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF256EFF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Tutup Riwayat",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF256EFF),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text("$label :", style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
