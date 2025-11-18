import 'package:flutter/material.dart';

class CallerPage extends StatelessWidget {
  final String uid;
  final String nama;
  final String loketID;
  const CallerPage({
    super.key,
    required this.uid,
    required this.nama,
    required this.loketID,
    required password,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Petugas: $nama")),
      body: Center(child: Text("Anda bertugas di $loketID")),
    );
  }
}
