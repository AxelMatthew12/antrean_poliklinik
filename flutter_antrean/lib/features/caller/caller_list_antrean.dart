import 'package:antrean_poliklinik/features/caller/caller_antrean_card.dart';
import 'package:antrean_poliklinik/features/caller/caller_antrean_detail.dart';
import 'package:antrean_poliklinik/features/caller/models/antrean_model.dart';
import 'package:antrean_poliklinik/widget/caller_list_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CallerListAntrean extends StatefulWidget {
  final String layananID;

  const CallerListAntrean({super.key, required this.layananID});

  @override
  State<CallerListAntrean> createState() => _CallerListAntreanState();
}

class _CallerListAntreanState extends State<CallerListAntrean> {
  String activeTab = "Menunggu";
  late DatabaseReference antreanRef;

  @override
  void initState() {
    super.initState();
    antreanRef = FirebaseDatabase.instance
        .ref()
        .child("antrean")
        .child(widget.layananID);
  }

  /// STREAM ANTREAN
  Stream<List<AntreanModel>> _getAntreanStream(String status) {
    return antreanRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries
          .map((e) => AntreanModel.fromMap(e.key, e.value))
          .where((a) => a.status.toLowerCase() == status.toLowerCase())
          .toList();
    });
  }

  /// UPDATE STATUS
  Future<void> _updateStatus(AntreanModel antrean, String newStatus) async {
    final pasienUID = antrean.pasienUID;

    await antreanRef.child(antrean.nomor).update({"status": newStatus});

    await FirebaseDatabase.instance
        .ref()
        .child("antrean_user")
        .child(pasienUID)
        .update({"status": newStatus});
  }

  /// POPUP KONFIRMASI
  Future<void> _showConfirmDialog({
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2B6BFF),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: const Text(
            "Lanjutkan Panggilan Urutan Pasien?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// TIDAK
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EDFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Tidak",
                    style: TextStyle(color: Color(0xFF2B6BFF)),
                  ),
                ),

                const SizedBox(width: 12),

                /// YA
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2B6BFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        const Text(
          "Antrean Pasien",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B6BFF),
          ),
        ),

        const SizedBox(height: 12),

        /// TAB MENU
        CallerListMenu(
          activeTab: activeTab,
          onTabChanged: (tab) {
            setState(() => activeTab = tab);
          },
        ),

        const SizedBox(height: 20),

        /// LIST ANTREAN
        Expanded(
          child: StreamBuilder<List<AntreanModel>>(
            stream: _getAntreanStream(activeTab),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final antreanList = snapshot.data!;

              if (antreanList.isEmpty) {
                return const Center(child: Text("Tidak ada antrean."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: antreanList.length,
                itemBuilder: (context, index) {
                  final antrean = antreanList[index];

                  /// === PERBAIKAN TOMBOL ===
                  String buttonText = "";
                  if (antrean.status == "menunggu") {
                    buttonText = "Layani";
                  } else if (antrean.status == "berjalan") {
                    buttonText = "Selesai";
                  } else if (antrean.status == "selesai") {
                    buttonText = "Detail";
                  }

                  return CallerAntreanCard(
                    poli: antrean.poli,
                    nomor: antrean.nomor,
                    waktu: antrean.waktu,
                    status: antrean.status,
                    buttonText: buttonText,
                    onPressed: () {
                      if (antrean.status == "menunggu") {
                        _showConfirmDialog(
                          title: "Layani Antrean",
                          confirmText: "Ya, Lanjut",
                          onConfirm: () => _updateStatus(antrean, "berjalan"),
                        );
                      } else if (antrean.status == "berjalan") {
                        _showConfirmDialog(
                          title: "Selesaikan Antrean",
                          confirmText: "Ya, Selesai",
                          onConfirm: () => _updateStatus(antrean, "selesai"),
                        );
                      }
                      /// === BUKA DETAIL ===
                      else if (antrean.status == "selesai") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CallerDetailAntrean(antrean: antrean),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
