import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailHistoryPage extends StatefulWidget {
  final String poliId;
  final String nomorAntrean;

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
  Map? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  // Loads queue detail data + patient profile
  Future<void> _loadDetail() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Load queue detail
      final queueRef = FirebaseDatabase.instance
          .ref("antrean/${widget.poliId}/${widget.nomorAntrean}");
      final queueSnap = await queueRef.get();

      if (queueSnap.exists) {
        data = queueSnap.value as Map;
      }

      // Load patient profile
      final pasienRef = FirebaseDatabase.instance.ref("pasien");
      final pasienSnap = await pasienRef.get();

      if (pasienSnap.exists) {
        for (var child in pasienSnap.children) {
          final d = child.value as Map;
          if (d["uid"] == uid) {
            userData = d;
            break;
          }
        }
      }

      setState(() => loading = false);
    } catch (e) {
      print("ERROR DETAIL: $e");
      loading = false;
      setState(() {});
    }
  }

  // Formats datetime text
  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return "-";
    return value.replaceAll("T", "   ");
  }

  // Converts poli ID to readable name
  String _formatPoliName(String id) {
    switch (id) {
      case "POLI_GIGI":
        return "Poli Gigi";
      case "POLI_UMUM":
        return "Poli Umum";
      case "POLI_ANAK":
        return "Poli Anak";
      default:
        return id;
    }
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
                        _buildHeader(),
                        const SizedBox(height: 25),
                        _buildAvatar(),
                        const SizedBox(height: 20),
                        _buildMiniCard(userData?["nama"] ?? "Nama Pasien"),
                        const SizedBox(height: 12),
                        _buildPhoneAndPoli(),
                        const SizedBox(height: 28),
                        _buildDetailTimeCard(),
                        const SizedBox(height: 30),
                        _buildCloseButton(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Header containing icon + queue number
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.local_hospital,
            size: 42, color: Color(0xFF256EFF)),
        Text(
          data!["nomor"] ?? "-",
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Color(0xFF256EFF),
          ),
        ),
      ],
    );
  }

  // Avatar containing user photo or name initial
  Widget _buildAvatar() {
    final hasPhoto =
        userData?["foto"] != null && userData!["foto"].toString().isNotEmpty;
    final initial = (userData?["nama"] ?? "U")[0].toUpperCase();

    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.blue.shade400,
      backgroundImage: hasPhoto ? NetworkImage(userData!["foto"]) : null,
      child: hasPhoto
          ? null
          : Text(
              initial,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  // Phone + Poli card row
  Widget _buildPhoneAndPoli() {
    final phone = userData?["no_hp"] ??
        FirebaseAuth.instance.currentUser!.phoneNumber ??
        "-";

    final poliName = _formatPoliName(data!["layanan_id"] ?? "-");

    return Row(
      children: [
        Expanded(child: _buildMiniCard(phone)),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniCard(poliName)),
      ],
    );
  }

  // Mini info card
  Widget _buildMiniCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF256EFF), width: 1.3),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF256EFF),
          ),
        ),
      ),
    );
  }

  // Detail time section card
  Widget _buildDetailTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF256EFF), width: 1.5),
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
          _buildInfoRow("Waktu Ambil", _formatTime(data!["waktu_ambil"])),
          _buildInfoRow("Waktu Panggil", _formatTime(data!["waktu_panggil"])),
          _buildInfoRow("Waktu Selesai", _formatTime(data!["waktu_selesai"])),
          _buildInfoRow("Status", data!["status"] ?? "-"),
          _buildInfoRow("Loket", data!["loket_id"] ?? "-"),
          _buildInfoRow("Layanan", data!["layanan_id"] ?? "-"),
        ],
      ),
    );
  }

  // Row layout for each detail item
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label :",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Close button
  Widget _buildCloseButton() {
    return SizedBox(
      width: 220,
      height: 48,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF256EFF), width: 2),
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
    );
  }
}
