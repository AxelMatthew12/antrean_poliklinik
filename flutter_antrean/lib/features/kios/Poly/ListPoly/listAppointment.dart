import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antrean_poliklinik/widget/kiosListMenu.dart'; // Ensure the import is correct
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/DetailPoly.dart';
import 'package:antrean_poliklinik/features/kios/Poly/Queue/AntreanPage.dart';
import 'package:antrean_poliklinik/features/kios/Poly/HistoryPage.dart';

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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF6FA8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
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
                  poli.deskripsi,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailAntreanPage(
                            poli: poli,
                            userData: userData,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF256EFF),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Informasi",
                      style: TextStyle(
                        color: Color(0xFF256EFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ================= KiosListAntrean Widget =================
class KiosListAntrean extends StatefulWidget {
  final Map? userData;

  const KiosListAntrean({super.key, this.userData});

  @override
  State<KiosListAntrean> createState() => _KiosListAntreanState();
}

class _KiosListAntreanState extends State<KiosListAntrean> {
  late DatabaseReference layananRef;
  String _activeTab = "List Poli"; // Default active tab

  @override
  void initState() {
    super.initState();

    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://antrian-rumah-sakit-pbl-default-rtdb.asia-southeast1.firebasedatabase.app",
    );

    layananRef = db.ref("layanan");
  }

Widget _buildTabContent() {
  if (_activeTab == "List Poli") {
    return _buildPoliList();
  } else if (_activeTab == "Antrean") {
    return const AntreanPage(); // Halaman antrean
  } else if (_activeTab == "Riwayat") {
    return const HistoryPage(); // Halaman riwayat
  } else {
    return const SizedBox();
  }
}

  // Fetch and display List Poli from Firebase
  Widget _buildPoliList() {
    return StreamBuilder(
      stream: layananRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.snapshot.value;

        if (data == null) {
          return const Center(child: Text("Tidak ada data layanan."));
        }

        final poliMap = Map<String, dynamic>.from(data as Map);
        final poliList = poliMap.entries.map((e) {
          final value = Map<String, dynamic>.from(e.value);
          return PoliModel(
            id: value["id"],
            nama: value["nama"],
            deskripsi: value["deskripsi"],
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: poliList.length,
          itemBuilder: (context, index) {
            return PoliCard(
              poli: poliList[index], // pass PoliModel
              userData: widget.userData, // pass userData
            );
          },
        );
      },
    );
  }

// Appointment placeholder
Widget _buildAppointmentList() {
  return AntreanPage(); // Memanggil widget AppointmentPage()
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          KiosListMenu( // Here we use the kiosListMenu widget for dynamic tab switching
            activeTab: _activeTab, // Pass active tab value
            onTabChanged: (tab) {
              setState(() {
                _activeTab = tab; // Update active tab
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildTabContent()), // Show content based on active tab
        ],
      ),
    );
  }

  // Header with title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: const [
          Spacer(),
          Text(
            "Pemeriksaan Pasien",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

// ================= PoliModel =================
class PoliModel {
  final String id;
  final String nama;
  final String deskripsi;

  PoliModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
  });
}
