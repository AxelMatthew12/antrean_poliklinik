import 'package:antrean_poliklinik/features/caller/pages/antrean/caller_antrean_card.dart';
import 'package:antrean_poliklinik/features/caller/pages/antrean/caller_antrean_detail.dart';
import 'package:antrean_poliklinik/features/caller/controllers/caller_controller.dart';
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
        .ref("antrean")
        .child(widget.layananID);
  }

  /// STREAM ANTREAN
  Stream<List<AntreanModel>> _getAntreanStream(String status) {
    return antreanRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries
          .map((e) {
            final item = Map<String, dynamic>.from(e.value);

            return AntreanModel.fromMap(e.key, item);
          })
          .where((a) => a.status.toLowerCase() == status.toLowerCase())
          .toList();
    });
  }

  /// UPDATE STATUS
  Future<void> _updateStatus(AntreanModel antrean, String newStatus) async {
    final pasienUID = antrean.pasienUID;

    // update untuk antrean_<layananID>
    await antreanRef.child(antrean.nomor).update({"status": newStatus});

    // update untuk antrean_user
    await FirebaseDatabase.instance.ref("antrean_user").child(pasienUID).update(
      {"status": newStatus},
    );
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
                    backgroundColor: Color(0xFFE8EDFF),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Tidak",
                    style: TextStyle(color: Color(0xFF2B6BFF)),
                  ),
                ),

                SizedBox(width: 12),

                /// YA
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2B6BFF),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
    // final caller = CallerController();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        child: Column(
          children: [
            Center(
              child: Text(
                "Antrean Pasien",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF256EFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            /// TAB MENU
            CallerListMenu(
              activeTab: activeTab,
              onTabChanged: (tab) {
                setState(() => activeTab = tab);
              },
            ),
            SizedBox(height: 0),

            /// LIST ANTREAN
            Expanded(
              child: StreamBuilder<List<AntreanModel>>(
                stream: _getAntreanStream(activeTab),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final antreanList = snapshot.data!;
                  if (antreanList.isEmpty) {
                    return Center(child: Text("Tidak ada antrean."));
                  }

                  return ListView.builder(
                    itemCount: antreanList.length,
                    itemBuilder: (context, index) {
                      final antrean = antreanList[index];

                      String buttonText = "";
                      if (antrean.status == "menunggu") {
                        buttonText = "Panggil";
                      } else if (antrean.status == "dilayani") {
                        buttonText = "Selesai";
                      } else if (antrean.status == "selesai") {
                        buttonText = "Detail";
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: CallerAntreanCard(
                          poli: antrean.layananID,
                          nomor: antrean.nomor,
                          waktu: antrean.waktu_ambil,
                          status: antrean.status,
                          buttonText: buttonText,
                          onPressed: () {
                            /// =============================
                            /// MENUNGGU → DIPANGGIL
                            /// =============================
                            if (antrean.status == "menunggu") {
                              _showConfirmDialog(
                                title: "Panggil Antrean",
                                confirmText: "Ya, Panggil",
                                onConfirm: () async {
                                  // 1) Update display TV + audio
                                  // await caller.updateDisplay(
                                  //   antrean.nomor,
                                  //   antrean.poli,
                                  // );

                                  // 2) Update status antrean → dilayani
                                  // await _updateStatus(antrean, "dilayani");
                                  await antreanRef.child(antrean.nomor).update({
                                    "status": "dilayani",
                                    "waktu_panggil": DateTime.now()
                                        .toIso8601String(),
                                  });
                                  await FirebaseDatabase.instance
                                      .ref("antrean_user/${antrean.pasienUID}")
                                      .update({
                                        "status": "dilayani",
                                        "waktu_panggil": DateTime.now()
                                            .toIso8601String(),
                                      });
                                },
                              );
                            }
                            /// =============================
                            /// dilayani → SELESAI
                            /// =============================
                            else if (antrean.status == "dilayani") {
                              _showConfirmDialog(
                                title: "Selesaikan Antrean",
                                confirmText: "Ya, Selesai",
                                onConfirm: () async {
                                  // await _updateStatus(antrean, "selesai");
                                  await antreanRef.child(antrean.nomor).update({
                                    "status": "selesai",
                                    "waktu_selesai": DateTime.now()
                                        .toIso8601String(),
                                  });
                                  await FirebaseDatabase.instance
                                      .ref("antrean_user/${antrean.pasienUID}")
                                      .update({
                                        "status": "selesai",
                                        "waktu_selesai": DateTime.now()
                                            .toIso8601String(),
                                      });
                                },
                              );
                            }
                            /// =============================
                            /// SELESAI → DETAIL
                            /// =============================
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
