import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antrean_poliklinik/widget/kiosListMenu.dart'; // Ensure the import is correct
import 'package:antrean_poliklinik/features/kios/detail_antrean.dart';
import 'package:antrean_poliklinik/features/kios/appoitment.dart';

// ================= PoliCard Widget =================
class PoliCard extends StatelessWidget {
  final PoliModel poli;
  final Map? userData;

  const PoliCard({super.key, required this.poli, this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: AssetImage("assets/profile.jpeg"),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poli.nama,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(poli.deskripsi, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Info"),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_month_rounded, color: Colors.black87),
                    const SizedBox(width: 12),
                    const Icon(Icons.info_outline_rounded, color: Colors.black87),
                    const SizedBox(width: 12),
                    const Icon(Icons.help_outline_rounded, color: Colors.black87),
                  ],
                ),
              ],
            ),
          )
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

  // Switch between different tab contents
  Widget _buildTabContent() {
    if (_activeTab == "List Poli") {
      return _buildPoliList(); // Show Poli list
    } else if (_activeTab == "Appointment") {
      return _buildAppointmentList(); // Show Appointment list
    } else {
      return const Center(child: Text("Riwayat Content"));
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
  return AppointmentPage(); // Memanggil widget AppointmentPage()
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
            "Kios Antrean",
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
