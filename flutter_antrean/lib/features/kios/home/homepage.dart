import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:antrean_poliklinik/features/kios/Profile/dashboardprofile.dart';
import 'package:antrean_poliklinik/widget/kios_bottom_nav.dart';
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/listAppointment.dart';
import 'package:antrean_poliklinik/features/kios/Settings/SettingProfile.dart';

class HomePage extends StatefulWidget {
  final Map? userData;

  const HomePage({super.key, this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  Map? userData;

  bool isLoadingHistory = true;
  List<Map> recentHistory = [];

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    _loadRecentHistory();
  }

  // =============================================================
  // 🔵 LOAD 3 RIWAYAT TERBARU (status = selesai)
  // =============================================================
  Future<void> _loadRecentHistory() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final antreanRef = FirebaseDatabase.instance.ref("antrean");

    final snapshot = await antreanRef.get();
    List<Map> temp = [];

    if (snapshot.exists) {
      for (var poliNode in snapshot.children) {
        for (var nomorNode in poliNode.children) {
          final data = nomorNode.value as Map;

          // Sama seperti HistoryPage
          if (data["pasien_uid"] == uid &&
              data["status"] == "selesai") {
            temp.add({
              "poli": poliNode.key,
              "nomor": data["nomor"],
              "deskripsi": "Pemeriksaan telah selesai.",
            });

            // 🔥 Jika sudah 3 data → cukup
            if (temp.length == 3) break;
          }
        }

        if (temp.length == 3) break;
      }
    }

    setState(() {
      recentHistory = temp;
      isLoadingHistory = false;
    });
  } catch (e) {
    print("ERROR load history homepage: $e");
    setState(() => isLoadingHistory = false);
  }
}



  // ================== NAVIGATION ==================
  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ================== UI BUILD ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),

      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: [
          _homePageContent(),
          DashboardProfile(userData: userData),
          const KiosListAntrean(),
        ],
      ),
    );
  }

  // ================== HOME PAGE CONTENT ==================
  Widget _homePageContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 20),

            const Text(
              "Riwayat Terbaru",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF256EFF),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : recentHistory.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada riwayat",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView(
                          children: recentHistory
                              .map((item) => HistoryCard(
                                    poliName: item["poli"],
                                    nomor: item["nomor"],
                                    description: item["deskripsi"],
                                  ))
                              .toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER ==================
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // FIX AVATAR AGAR TIDAK ERROR ASSET
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: (userData?['foto'] != null &&
                      userData!['foto'].toString().isNotEmpty)
                  ? NetworkImage(userData!['foto'])
                  : null,
              child: (userData?['foto'] == null ||
                      userData!['foto'].toString().isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi, WelcomeBack",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                Text(
                  userData?['nama'] ?? "No Name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            _topIcon(Icons.notifications_none),
            const SizedBox(width: 10),
            _topIcon(
              Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingProfile()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ================= ICON HEADER ==================
  Widget _topIcon(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 69, 163, 239),
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }
}

// =====================================================================
// 🔵 WIDGET CARD RIWAYAT
// =====================================================================

class HistoryCard extends StatelessWidget {
  final String poliName;
  final String nomor;
  final String description;

  const HistoryCard({
    super.key,
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
        border: Border.all(
          color: Color(0xFF256EFF),
          width: 1.6,
        ),
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
              const Icon(
                Icons.history,
                size: 50,
                color: Color(0xFF256EFF),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                side: const BorderSide(
                  color: Color(0xFF256EFF),
                  width: 1.5,
                ),
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
