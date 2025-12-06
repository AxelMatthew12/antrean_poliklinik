import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antrean_poliklinik/widget/kiosListMenu.dart';
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/DetailPoly.dart';
import 'package:antrean_poliklinik/features/kios/Poly/Queue/AntreanPage.dart';
import 'package:antrean_poliklinik/features/kios/Poly/Queue/HistoryPage.dart';


// ============================================================
// POLI CARD ITEM
// ============================================================
class PoliCard extends StatelessWidget {
  final PoliModel poli;
  final Map? userData;

  const PoliCard({super.key, required this.poli, this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE6FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poli image
          _buildImage(),

          const SizedBox(width: 16),

          // Name, description, and button
          Expanded(child: _buildInfoSection(context)),
        ],
      ),
    );
  }

  // Poli image widget
  Widget _buildImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          poli.gambar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32, color: Colors.grey),
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      ),
    );
  }

  // Text + button section
  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          poli.nama,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF256EFF),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          poli.deskripsi.length > 70
              ? '${poli.deskripsi.substring(0, 70)}...'
              : poli.deskripsi,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 34,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailAntreanPage(poli: poli, userData: userData),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF256EFF), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              "Informasi",
              style: TextStyle(
                color: Color(0xFF256EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MAIN LIST PAGE (LIST POLI / ANTREAN / RIWAYAT)
// ============================================================

class KiosListAntrean extends StatefulWidget {
  final Map? userData;

  const KiosListAntrean({super.key, this.userData});

  @override
  State<KiosListAntrean> createState() => _KiosListAntreanState();
}

class _KiosListAntreanState extends State<KiosListAntrean> {
  late DatabaseReference layananRef;
  String activeTab = "List Poli";

  @override
  void initState() {
    super.initState();
    layananRef = FirebaseDatabase.instance.ref("layanan");  
  }

  // Switch content based on selected tab
  Widget _buildTabContent() {
    switch (activeTab) {
      case "List Poli":
        return _buildPoliList();
      case "Antrean":
        return const AntreanPage();
      case "Riwayat":
        return const HistoryPage();
      default:
        return const SizedBox();
    }
  }

  // Build poli list from Firebase
  Widget _buildPoliList() {
    return StreamBuilder(
      stream: layananRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawData = snapshot.data!.snapshot.value;
        if (rawData == null) {
          return const Center(child: Text("Tidak ada data layanan."));
        }

        // Convert Firebase map to usable model
        final poliMap = Map<String, dynamic>.from(rawData as Map);

        final poliList = poliMap.entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          return PoliModel(
            id: item["id"] ?? "",
            nama: item["nama"] ?? "",
            deskripsi: item["deskripsi"] ?? "",
            gambar: item["gambar"] ?? "",
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: poliList.length,
          itemBuilder: (_, index) {
            return PoliCard(
              poli: poliList[index],
              userData: widget.userData,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          KiosListMenu(
            activeTab: activeTab,
            onTabChanged: (tab) {
              setState(() => activeTab = tab);
            },
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: const [
          Spacer(),
          Text(
            "Pemeriksaan Pasien",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}



// ============================================================
// POLI MODEL
// ============================================================

class PoliModel {
  final String id;
  final String nama;
  final String deskripsi;
  final String gambar;

  PoliModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.gambar,
  });
}
