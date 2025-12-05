import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String uid;
  bool isLoading = true;
  List<Map> historyList = [];

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final antreanRef = FirebaseDatabase.instance.ref("antrean");
      final snapshot = await antreanRef.get();

      List<Map> temp = [];

      if (snapshot.exists) {
        for (var poliNode in snapshot.children) {
          String poliId = poliNode.key ?? "-";

          for (var nomorNode in poliNode.children) {
            if (nomorNode.value is! Map) continue;

            final data = nomorNode.value as Map;

            if (data["pasien_uid"] == uid && data["status"] == "selesai") {
              temp.add({
                "poli_id": poliId,
                "poli_name": _formatPoliName(poliId),
                "nomor": data["nomor"]?.toString() ?? "-",
                "deskripsi": data["deskripsi"] ?? "Pemeriksaan telah selesai.",
                "timestamp": data["timestamp"] ?? 0,
              });
            }
          }
        }
      }

      int extractNumber(String value) {
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(digits) ?? 0;
      }

      temp.sort((a, b) {
        // Urutkan berdasarkan nama poli
        int poliSort = a["poli_name"].compareTo(b["poli_name"]);
        if (poliSort != 0) return poliSort;

        // Jika poli sama → urutkan nomor antrean berdasarkan angka
        int numA = extractNumber(a["nomor"]);
        int numB = extractNumber(b["nomor"]);
        return numA.compareTo(numB);
      });

      setState(() {
        historyList = temp;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatPoliName(String poliId) {
    switch (poliId) {
      case "poli_umum":
        return "Poli Umum";
      case "poli_gigi":
        return "Poli Gigi";
      case "poli_anak":
        return "Poli Anak";
      default:
        return poliId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
          ? const Center(
              child: Text(
                "Anda belum memiliki riwayat",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: historyList.map((item) {
                  return _HistoryCard(
                    poliName: item["poli_name"],
                    nomor: item["nomor"],
                    description: item["deskripsi"],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String poliName;
  final String nomor;
  final String description;

  const _HistoryCard({
    required this.poliName,
    required this.nomor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color(0xFF256EFF), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                poliName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF256EFF),
                ),
              ),
              const Spacer(),
              Text(
                nomor,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF256EFF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.history, size: 50, color: Color(0xFF256EFF)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 8,
                ),
                side: const BorderSide(color: Color(0xFF256EFF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Detail",
                style: TextStyle(
                  color: Color(0xFF256EFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
