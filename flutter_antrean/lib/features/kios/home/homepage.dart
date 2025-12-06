import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antrean_poliklinik/features/kios/Profile/dashboardprofile.dart';
import 'package:antrean_poliklinik/widget/kios_bottom_nav.dart';
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/listAppointment.dart';
import 'package:antrean_poliklinik/widget/kios_header.dart';
import 'package:antrean_poliklinik/features/kios/Poly/Queue/DetailHistory.dart';
import 'package:antrean_poliklinik/features/kios/Settings/Notification/notification_alert.dart';

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

    /// Load data user terbaru
    _loadUserData();

    /// Start realtime listener for history
    _listenRecentHistory();

    /// Start popup notification listener — hanya di HomePage!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationAlert.startListening(
        context: context,
        notifEnabled: true,
      );
    });
  }

  // ============================================================
  // 🔥 LOAD USER DATA TERBARU DARI FIREBASE
  // ============================================================
  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pasienRef = FirebaseDatabase.instance.ref("pasien");
    final snapshot = await pasienRef.get();

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        final d = Map<String, dynamic>.from(child.value as Map);

        if (d["uid"] == uid) {
          setState(() {
            userData = d;
          });
          break;
        }
      }
    }
  }

  /// ============================================================
  /// 🔥 LISTENER DATA RIWAYAT REALTIME
  /// ============================================================
  void _listenRecentHistory() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final antreanRef = FirebaseDatabase.instance.ref("antrean");

    antreanRef.onValue.listen((event) {
      if (!mounted) return;

      List<Map> temp = [];
      final snapshot = event.snapshot;

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
                "nomor": data["nomor"].toString(),
                "waktu_selesai": data["waktu_selesai"] ?? "",
                "deskripsi": "Pemeriksaan telah selesai.",
              });
            }
          }
        }
      }

      temp.sort((a, b) {
        final tA = DateTime.tryParse(a["waktu_selesai"] ?? "") ?? DateTime(2000);
        final tB = DateTime.tryParse(b["waktu_selesai"] ?? "") ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      final latest3 = temp.length > 3 ? temp.sublist(0, 3) : temp;

      setState(() {
        recentHistory = latest3;
        isLoadingHistory = false;
      });
    });
  }

  /// Format nama poli
  String _formatPoliName(String id) {
    switch (id) {
      case "poli_umum":
        return "Poli Umum";
      case "poli_gigi":
        return "Poli Gigi";
      case "poli_anak":
        return "Poli Anak";
      default:
        return id;
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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

          const KiosListAntrean(),

          /// DashboardProfile sekarang ada callback refresh
          DashboardProfile(
            userData: userData,
            onUpdate: _loadUserData, // 🔥 HOME AUTO REFRESH NAMA
          ),
        ],
      ),
    );
  }

  /// ============================================================
  /// HOME UI
  /// ============================================================
  Widget _homePageContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KiosHeaderWidget(userData: userData),

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
                          children: recentHistory.map((item) {
                            return HistoryCard(
                              poliId: item["poli_id"] ?? "-",
                              poliName: item["poli_name"] ?? "-",
                              nomor: item["nomor"] ?? "-",
                              description: item["deskripsi"] ?? "",
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================== //
//                            HISTORY CARD                               //
// ===================================================================== //
class HistoryCard extends StatelessWidget {
  final String poliId;
  final String poliName;
  final String nomor;
  final String description;

  const HistoryCard({
    super.key,
    required this.poliId,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailHistoryPage(
                      poliId: poliId,
                      nomorAntrean: nomor,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
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
