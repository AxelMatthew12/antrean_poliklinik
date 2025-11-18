import 'package:flutter/material.dart';

class PasienPage extends StatelessWidget {
  final String nama;
  final String nik;
  final String email;
  final String alamat;
  final String noHP;
  final String tanggalLahir;

  const PasienPage({
    super.key,
    required this.nama,
    required this.nik,
    required this.email,
    required this.alamat,
    required this.noHP,
    required this.tanggalLahir, required uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Pasien"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  nama,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                Text("NIK:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  nik,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                Text("Email:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  email,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                Text("Nomor HP:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  noHP,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                Text("Tanggal Lahir:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  tanggalLahir,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                Text("Alamat:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(
                  alamat,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
