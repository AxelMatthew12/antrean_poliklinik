import 'package:flutter/material.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  int selectedTab = 0;      // Tracks active tab (0 = FAQ, 1 = Contact)
  int previousTab = 0;      // Tracks previous tab for slide direction

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
              child: Text(
                "Bagaimana Kami Dapat Membantu Kamu?\n"
                "Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  height: 1.4,
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
          children: [
            _tabButton("FAQ", 0),
            _tabButton("Kontak Kami", 1),
          ],
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
            borderRadius: BorderRadius.circular(30),
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
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
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
  Widget _faqContent({Key? key}) {
    final faqItems = [
      "Apa itu Click Queue?",
      "Lorem ipsum dolor sit amet?",
      "Bagaimana cara mengambil antrean?",
      "Apa manfaat menggunakan aplikasi ini?",
    ];

    return ListView.separated(
      key: key,
      itemCount: faqItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, index) => _faqItem(faqItems[index]),
    );
  }

  // -------------------------------------------------------------
  // Single FAQ card item
  // -------------------------------------------------------------
  Widget _faqItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF256EFF),
          width: 1.4,
        ),
      ),
      child: Row(
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
          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF256EFF)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Contact content list
  // -------------------------------------------------------------
  Widget _contactContent({Key? key}) {
    final items = [
      {"title": "Customer Service", "icon": Icons.support_agent},
      {"title": "Website", "icon": Icons.language},
      {"title": "WhatsApp", "icon": Icons.chat},
      {"title": "Instagram", "icon": Icons.camera_alt},
      {"title": "Facebook", "icon": Icons.facebook},
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF256EFF), width: 1.4),
      ),
      child: Row(
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF256EFF),
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF256EFF)),
        ],
      ),
    );
  }
}
