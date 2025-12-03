import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AntreanPage extends StatefulWidget {
  const AntreanPage({super.key});

  @override
  State<AntreanPage> createState() => _AntreanPageState();
}

class _AntreanPageState extends State<AntreanPage> {
  bool _isLoading = true;

  String _userNomor = "-";
  String _userStatus = "-"; 
  String _poliId = "-";

  String _currentServed = "-"; 
  int _position = 0; 

  @override
  void initState() {
    super.initState();
    _loadAntrean();
  }


  Future<void> _loadAntrean() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

      final userSnap =
          await FirebaseDatabase.instance.ref("antrean_user/$uid").get();

      if (!userSnap.exists) {
        setState(() {
          _isLoading = false;
          _userStatus = "Tidak ada antrean";
        });
        return;
      }

      final data = userSnap.value as Map;
      _poliId = data["poli_id"];
      _userNomor = data["nomor"].toString();
      _userStatus = data["status"] ?? "-";


      if (_userStatus.toLowerCase() == "selesai") {
        await FirebaseDatabase.instance.ref("antrean_user/$uid").remove();
        await FirebaseDatabase.instance
            .ref("antrean/$_poliId/${_userNomor}")
            .remove();

        setState(() {
          _userNomor = "-";
          _userStatus = "Tidak ada antrean";
          _position = 0;
          _isLoading = false;
        });

        return;
      }

  
      final poliSnap =
          await FirebaseDatabase.instance.ref("antrean/$_poliId").get();

      List antreanList = [];
      String served = "-";

      if (poliSnap.exists) {
        for (var child in poliSnap.children) {
          final a = child.value as Map;
          antreanList.add(a);

          if (a["status"] == "berjalan") {
            served = a["nomor"].toString();
          }
        }
      }

      antreanList.sort((a, b) => a["nomor"].compareTo(b["nomor"]));

      int pos = 0;
      for (var a in antreanList) {
        if (a["status"] == "menunggu") {
          pos++;
          if (a["nomor"].toString() == _userNomor) break;
        }
      }

      setState(() {
        _currentServed = served;
        _position = pos;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }


  Future<void> _showCancelDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Batalkan Antrean",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF256EFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Apakah anda yakin ingin\nmembatalkan antrean pemeriksaan?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 26),

                Row(
                  children: [
              
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE3E9FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Tidak",
                            style: TextStyle(
                              color: Color(0xFF256EFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

             
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            final uid =
                                FirebaseAuth.instance.currentUser!.uid;

                            await FirebaseDatabase.instance
                                .ref("antrean_user/$uid")
                                .remove();

                            await FirebaseDatabase.instance
                                .ref("antrean/$_poliId/${_userNomor}")
                                .remove();

                            setState(() {
                              _userNomor = "-";
                              _userStatus = "Tidak ada antrean";
                              _position = 0;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Antrean berhasil dibatalkan."),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF256EFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Ya, Batalkan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
    
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF256EFF),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Nomor Sedang Dilayani",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentServed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Silakan menunggu giliran Anda",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFF256EFF),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Antrean Anda",
                          style: TextStyle(
                            color: Color(0xFF256EFF),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          _userNomor,
                          style: const TextStyle(
                            color: Color(0xFF256EFF),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Posisi Anda: $_position",
                          style: const TextStyle(
                            color: Color(0xFF256EFF),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (_userStatus != "selesai" &&
                            _userStatus != "Tidak ada antrean" &&
                            _userNomor != "-")
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => _showCancelDialog(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF256EFF), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Cancel Antrean",
                                style: TextStyle(
                                  color: Color(0xFF256EFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
