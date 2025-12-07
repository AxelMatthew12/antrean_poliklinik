import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  int selectedTab = 0; // Tracks active tab (0 = FAQ, 1 = Contact)
  int previousTab = 0; // Tracks previous tab for slide direction

  int? _expandedIndex; // menyimpan index card yang dibuka

  // bagian call center
  Future<void> _callNumber(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Tidak dapat membuka aplikasi telepon.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF256EFF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Page header with back button and title
            _buildHeader(),

            const SizedBox(height: 16),

            // Description text section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // JUDUL (lebih tebal)
                  Text(
                    "Bagaimana Kami Dapat Membantu Kamu?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // TEKS LEBIH TEBAL
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 6),

                  // DESKRIPSI (lebih ringan)
                  Text(
                    "Panduan aplikasi dan info layanan tersedia di sini. Pilih kategori bantuan untuk melanjutkan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab selection menu (FAQ / Contact)
            _buildTabMenu(),

            const SizedBox(height: 16),

            // Dynamic content area with slide animation
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: _buildAnimatedContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Header section Back button + Title
  // -------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Pusat Bantuan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Tab container background + padding
  // -------------------------------------------------------------
  Widget _buildTabMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [_tabButton("FAQ", 0), _tabButton("Kontak Kami", 1)],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Single tab button widget
  // -------------------------------------------------------------
  Widget _tabButton(String label, int index) {
    final bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            previousTab = selectedTab;
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF256EFF) : const Color(0xFFE5E9FF),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: active ? Colors.white : const Color(0xFF256EFF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Animated content switcher (FAQ , Contact)
  // -------------------------------------------------------------
  Widget _buildAnimatedContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        final slideRight = selectedTab > previousTab;

        final offsetAnimation = Tween<Offset>(
          begin: slideRight ? const Offset(1, 0) : const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: selectedTab == 0
          ? _faqContent(key: const ValueKey("faq"))
          : _contactContent(key: const ValueKey("contact")),
    );
  }

  // -------------------------------------------------------------
  // FAQ content list
  // -------------------------------------------------------------

  // tambahan data faq
  final faqItems = [
    {
      "title": "Apa itu klik Antri?",
      "desc":
          "Klik Antri adalah aplikasi antrean digital Poliklinik POLINEMA yang mempermudah pasien untuk mengambil nomor antrean secara online.",
    },
    {
      "title": "Alamat Poliklinik POLINEMA?",
      "desc":
          "Jl. MT. Haryono No.72, Jatimulyo, Lowokwaru, Kota Malang, Jawa Timur 65145.",
    },
    {
      "title": "Bagaimana cara mengambil antrean?",
      "desc":
          "1. Masuk ke aplikasi\n"
          "2. pilih menu pemeriksaan pasien\n"
          "3. pilih layanan poliklinik\n"
          "4. klik tombol informasi\n"
          "5. kemudian tekan tombol 'Ambil Antrean Poli'\n"
          "6. Kembali dan Masuk ke navigasi Antreanv\n"
          "7. Nomor antrean akan muncul otomatis.",
    },
    {
      "title": "Apa manfaat menggunakan aplikasi ini?",
      "desc":
          "Menghemat waktu, mengurangi antrean fisik, dan memudahkan pasien melacak progres antrean secara real-time.",
    },
  ];

  Widget _faqContent({Key? key}) {
    return ListView.separated(
      key: key,
      itemCount: faqItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, index) {
        final item = faqItems[index];
        return _faqItem(
          title: item["title"]!,
          desc: item["desc"]!,
          isExpanded: _expandedIndex == index,
          onTap: () {
            setState(() {
              _expandedIndex = (_expandedIndex == index) ? null : index;
            });
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Single FAQ card item
  // -------------------------------------------------------------
  Widget _faqItem({
    required String title,
    required String desc,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF256EFF), width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF256EFF),
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 22,
                  color: const Color(0xFF256EFF),
                ),
              ],
            ),

            // DESKRIPSI (muncul saat expanded)
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Contact content list
  // -------------------------------------------------------------
  Widget _contactContent({Key? key}) {
    final items = [
      // {"title": "Customer Service", "icon": Icons.support_agent},
      // {"title": "Website", "icon": Icons.language},
      // {"title": "WhatsApp", "icon": Icons.chat},
      // {"title": "Instagram", "icon": Icons.camera_alt},
      // {"title": "Facebook", "icon": Icons.facebook},
      {"title": "Call Center Poliklinik", "icon": Icons.call},
    ];

    return ListView.separated(
      key: key,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, index) => _contactItem(
        items[index]["title"] as String,
        items[index]["icon"] as IconData,
      ),
    );
  }

  // -------------------------------------------------------------
  // Single Contact card item
  // -------------------------------------------------------------
  Widget _contactItem(String title, IconData icon) {
    final nomorTelepon = "0341-404424";
    final isCallCenter = title == "Call Center Poliklinik";

    return InkWell(
      onTap: () {
        if (isCallCenter) {
          _callNumber(nomorTelepon);
        }
        // Tambahkan onTap lain kalau mau untuk menu lain
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF256EFF), width: 1.4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFF256EFF), size: 22),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF256EFF),
                    ),
                  ),
                  if (isCallCenter)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        nomorTelepon,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF256EFF),
            ),
          ],
        ),
      ),
    );
  }
}
