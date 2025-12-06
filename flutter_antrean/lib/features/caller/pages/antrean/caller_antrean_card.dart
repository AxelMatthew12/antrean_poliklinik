import 'package:flutter/material.dart';

class CallerAntreanCard extends StatelessWidget {
  final String poli;
  final String nomor;
  final String waktu;
  final String status;
  final VoidCallback? onPressed;
  final String buttonText;

  const CallerAntreanCard({
    super.key,
    required this.poli,
    required this.nomor,
    required this.waktu,
    required this.status,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF256EFF), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// === TOP: Poli + Nomor ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                poli,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF256EFF),
                ),
              ),
              Text(
                nomor,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF256EFF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// === MIDDLE: Avatar + Info Pasien ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Color.fromARGB(255, 64, 100, 220),
                ),
              ),

              //const CircleAvatar(
              //radius: 32,
              //backgroundImage: AssetImage("assets/profile/profile.jpeg"),
              //),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Waktu Ambil: $waktu",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status: $status",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// === BUTTON: Layani / Selesai / Panggil ===
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF256EFF), // Warna biru
                  foregroundColor: Colors.white, // Text putih
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
