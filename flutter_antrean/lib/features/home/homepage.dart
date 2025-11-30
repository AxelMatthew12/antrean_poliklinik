import 'package:flutter/material.dart';
import 'package:antrean_poliklinik/features/profile/dashboardprofile.dart';
import 'package:antrean_poliklinik/widget/custom_bottom_nav.dart';
import 'package:antrean_poliklinik/features/kios/kios_antrean.dart';

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

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  // ================== FIXED! NAVIGATION ==================
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
          _homePageContent(),                   // INDEX 0
          DashboardProfile(userData: userData), // INDEX 1
          const KiosListAntrean(),              // INDEX 2
        ],
      ),
    );
  }

  // ================== HOME CONTENT ==================
  Widget _homePageContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: userData?['foto'] != null
                          ? NetworkImage(userData!['foto'])
                          : const AssetImage("assets/profile.jpeg")
                              as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi, WelcomeBack",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 12),
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
                    _topIcon(Icons.settings),
                  ],
                ),
              ],
            ),

            // BODY
            Expanded(
              child: Center(
                child: Text(
                  "Anda Belum Memiliki Riwayat",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.blue),
    );
  }
}
