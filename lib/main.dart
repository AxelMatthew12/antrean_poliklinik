import 'package:antrean_poliklinik/features/caller/controllers/caller_controller.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';
import 'package:antrean_poliklinik/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final kios = KiosController();
  final caller = CallerController();

  print("=== STEP 1: AMBIL NOMOR ===");
  final nomor = await kios.ambilNomor("POLI_UMUM", "A003");
  print("Nomor yang diambil pasien = $nomor");

  print("=== STEP 2: PANGGIL NOMOR ===");
  await caller.panggil("POLI_UMUM", "LOKET_01");

  print("=== STEP 3: CEK YANG SEDANG DILAYANI ===");
  final sedang = await caller.getSedangDilayani("POLI_UMUM");
  print("Sedang dilayani: $sedang");

  print("=== STEP 4: SELESAIKAN ===");
  if (sedang != null) {
    await caller.selesaikan("POLI_UMUM", sedang);
  } else {
    print("Tidak ada antrean yang sedang dilayani.");
  }
}