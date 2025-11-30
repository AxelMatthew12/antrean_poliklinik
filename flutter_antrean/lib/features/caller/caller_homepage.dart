import 'package:flutter/material.dart';
import 'caller_list_antrean.dart';
import 'caller_profile.dart';
import '../../widget/caller_bottom_nav.dart';

class CallerPage extends StatefulWidget {
  final String uid;
  final String nama;
  final String loketID; // Loket petugas, ex: LKT01/LKT02/LKT03
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

  /// Mapping dari Loket → Poli
  final Map<String, String> loketToPoli = {
    "LKT01": "POLI_UMUM",
    "LKT02": "POLI_GIGI",
    "LKT03": "POLI_ANAK",
  };

  @override
  Widget build(BuildContext context) {
    // → Ambil POLI berdasarkan loket yang login
    final layananID = loketToPoli[widget.loketID] ?? "POLI_UMUM";

    return Scaffold(
      backgroundColor: Colors.white,

      // backgroundColor: Colors.purple,
      body: Stack(
        children: [
          SafeArea(
            child: _selectedIndex == 0
                ? CallerListAntrean(layananID: layananID)
                : CallerProfilePage(
                    uid: widget.uid,
                    nama: widget.nama,
                    loketID: widget.loketID,
                    email: widget.email,
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: CallerBottomNav(
                currentIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
