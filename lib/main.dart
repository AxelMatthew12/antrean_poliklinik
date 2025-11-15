import 'package:antrean_poliklinik/features/caller/controllers/caller_controller.dart';
import 'package:antrean_poliklinik/firebase_options.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // final tester = KiosController();

  // // gunakan UID dummy untuk testing
  // const testPasienUid = "UID_TEST_003";

  // final nomor = await tester.ambilNomor("POLI_UMUM", testPasienUid);

  // print("HASIL TEST LOGIKA ANTREAN => $nomor");
  // print("Jika A001 atau A002 muncul, berarti logika berhasil");

  final kios = KiosController();
  final caller = CallerController();

  // KIOS ambil nomor (test)
  await kios.ambilNomor("POLI_UMUM", "A002");

  // CALLER memanggil antrean
  await caller.panggil("POLI_UMUM", "LOKET_01");
}
