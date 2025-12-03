import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AntreanModel {
  final String id;
  final String nomor;
  final String poli;
  final String status;

  AntreanModel({
    required this.id,
    required this.nomor,
    required this.poli,
    required this.status,
  });
}

class CallerListAntrean extends StatefulWidget {
  final String layananID;

  const CallerListAntrean({super.key, required this.layananID});

  @override
  State<CallerListAntrean> createState() => _CallerListAntreanState();
}

class _CallerListAntreanState extends State<CallerListAntrean> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("antrian");
  List<AntreanModel> antreanList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _listenAntrean();
  }

  /// LISTEN FIREBASE
  void _listenAntrean() {
    ref.child(widget.layananID).onValue.listen((event) {
      antreanList.clear();

      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        data.forEach((key, value) {
          antreanList.add(AntreanModel(
            id: key,
            nomor: value["nomor"] ?? "-",
            poli: value["poli"] ?? widget.layananID,
            status: value["status"] ?? "menunggu",
          ));
        });

        /// SORT NOMOR
        antreanList.sort((a, b) {
          return int.parse(a.nomor).compareTo(int.parse(b.nomor));
        });
      }

      setState(() => loading = false);
    });
  }

  /// UPDATE STATUS ANTREAN
  Future<void> _updateStatus(AntreanModel antrean, String statusBaru) async {
    await ref
        .child(widget.layananID)
        .child(antrean.id)
        .update({"status": statusBaru});
  }

  /// KIRIM KE DISPLAY
  Future<void> _panggilKeDisplay(AntreanModel antrean) async {
    await FirebaseDatabase.instance.ref("antrian_display").update({
      "nomor": antrean.nomor,
      "loket": antrean.poli,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// MEMANGGIL NOMOR BERIKUTNYA
  Future<void> _panggilBerikutnya() async {
    // Cari antrean status menunggu
    final menunggu = antreanList.where((a) => a.status == "menunggu").toList();

    if (menunggu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada antrean menunggu.")),
      );
      return;
    }

    final next = menunggu.first;

    // Update status menjadi berjalan
    await _updateStatus(next, "berjalan");

    // Kirim ke display
    await _panggilKeDisplay(next);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Memanggil nomor ${next.nomor}")),
    );
  }

  /// POPUP KONFIRMASI
  void _showConfirmDialog({
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(confirmText),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 10),

        /// TOMBOL PANGGIL NOMOR BERIKUTNYA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: _panggilBerikutnya,
            icon: const Icon(Icons.volume_up),
            label: const Text("Panggil Nomor Berikutnya"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: antreanList.isEmpty
              ? const Center(child: Text("Belum ada antrean"))
              : ListView.builder(
                  itemCount: antreanList.length,
                  itemBuilder: (context, index) {
                    final antrean = antreanList[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(antrean.nomor),
                        ),
                        title: Text("Nomor Antrian ${antrean.nomor}"),
                        subtitle: Text("Status: ${antrean.status}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            if (antrean.status == "menunggu") {
                              _showConfirmDialog(
                                title: "Layani Antrean",
                                confirmText: "Lanjut",
                                onConfirm: () async {
                                  await _updateStatus(antrean, "berjalan");
                                  await _panggilKeDisplay(antrean);
                                },
                              );
                            } else if (antrean.status == "berjalan") {
                              _showConfirmDialog(
                                title: "Selesaikan",
                                confirmText: "Selesai",
                                onConfirm: () =>
                                    _updateStatus(antrean, "selesai"),
                              );
                            } else if (antrean.status == "selesai") {
                              _showConfirmDialog(
                                title: "Kembalikan ke Menunggu",
                                confirmText: "Kembalikan",
                                onConfirm: () =>
                                    _updateStatus(antrean, "menunggu"),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
