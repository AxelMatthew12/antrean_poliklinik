import 'package:antrean_poliklinik/features/caller/slide_gesture_wrapper.dart';
import 'package:flutter/material.dart';
import 'caller_list_antrean.dart';
import 'caller_profile.dart';
import '../../widget/caller_bottom_nav.dart';

class CallerPage extends StatefulWidget {
  final String uid;
  final String nama;
  final String loketID;
  final String email;

  const CallerPage({
    super.key,
    required this.uid,
    required this.nama,
    required this.loketID,
    required this.email,
  });

  @override
  State<CallerPage> createState() => _CallerPageState();
}

class _CallerPageState extends State<CallerPage> {
  int _selectedIndex = 0;

  late PageController _pageController;

  /// Loket → Poli
  final Map<String, String> loketToPoli = {
    "LKT01": "POLI_UMUM",
    "LKT02": "POLI_GIGI",
    "LKT03": "POLI_ANAK",
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  /// Pindah halaman dengan animasi slide
  void _animateToPage(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layananID = loketToPoli[widget.loketID] ?? "POLI_UMUM";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// PAGE VIEW — bisa swipe
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: [
              /// PAGE 0 → LIST ANTREAN (slide ke kiri)
              SlideGestureWrapper(
                slideToLeft: true,
                child: CallerListAntrean(layananID: layananID),
              ),

              /// PAGE 1 → PROFILE (slide ke kanan)
              SlideGestureWrapper(
                slideToLeft: false,
                child: CallerProfilePage(
                  uid: widget.uid,
                  nama: widget.nama,
                  loketID: widget.loketID,
                  email: widget.email,
                ),
              ),
            ],
          ),

          /// BOTTOM NAV
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: CallerBottomNav(
                currentIndex: _selectedIndex,
                onTap: (i) => _animateToPage(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
