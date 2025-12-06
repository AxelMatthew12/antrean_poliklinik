// import 'package:antrean_poliklinik/core/antrean_service.dart';
// import 'package:firebase_database/firebase_database.dart';

// final antreanService = AntreanService();

// class CallerController {
//   /// =========================================================
//   /// PANGGIL ANTREAN BERIKUTNYA
//   /// =========================================================
//   Future<void> panggil(String layananId, String loketId) async {
//     try {
//       // PROSES RESMI dari AntreanService
//       final result = await antreanService.panggilAntreanBerikutnya(
//         layananId,
//         loketId,
//       );

//       if (result == null) {
//         print("❗ Tidak ada antrean menunggu.");
//         return;
//       }

//       final nomor = result['nomor'];
//       final kodeLayanan = result['data']['layanan_id'];

//       // MAPPING POLI
//       final poli = _mapLayananKePoli(kodeLayanan);

//       if (poli == null) {
//         print("ERROR: layanan_id $kodeLayanan tidak dikenali.");
//         return;
//       }

//       print("Memanggil antrean: $nomor | POLI: $poli");

//       // UPDATE DISPLAY
//       await updateDisplay(nomor, poli);
//     } catch (e) {
//       print("Error saat memanggil antrean: $e");
//     }
//   }

//   /// =========================================================
//   /// MAPPING
//   /// =========================================================
//   String? _mapLayananKePoli(String kode) {
//     switch (kode) {
//       case "POLI_UMUM":
//         return "UMUM";
//       case "POLI_GIGI":
//         return "GIGI";
//       case "POLI_ANAK":
//         return "ANAK";
//       case "POLI_BEDAH":
//         return "BEDAH";
//       default:
//         return null;
//     }
//   }

//   /// =========================================================
//   /// UPDATE DISPLAY SAJA (JANGAN UPDATE ANTREAN LAGI!)
//   /// =========================================================
//   Future<void> updateDisplay(String nomor, String poli) async {
//     try {
//       await FirebaseDatabase.instance.ref("display/$poli").set({
//         "nomor": nomor,
//         "poli": poli,
//         "status": "dipanggil",
//         "timestamp": ServerValue.timestamp,
//       });

//       print("Display updated: Layar [$poli] menampilkan $nomor");
//     } catch (e) {
//       print("Error update display: $e");
//     }
//   }

//   /// =========================================================
//   /// GET DILAYANI
//   /// =========================================================
//   Future<String?> getSedangDilayani(String layananId) async {
//     try {
//       return await antreanService.getSedangDilayani(layananId);
//     } catch (e) {
//       print("Error getSedangDilayani: $e");
//       return null;
//     }
//   }

//   /// =========================================================
//   /// SELESAIKAN
//   /// =========================================================
//   Future<void> selesaikan(String layananId, String nomorAntrean) async {
//     try {
//       final success = await antreanService.selesaikanAntrean(
//         layananId,
//         nomorAntrean,
//       );

//       if (success) {
//         print("Antrean $nomorAntrean telah selesai.");
//       }
//     } catch (e) {
//       print("Error saat menyelesaikan antrean: $e");
//     }
//   }

//   /// =========================================================
//   /// BATALKAN
//   /// =========================================================
//   Future<void> batalkan(String layananId, String nomorAntrean) async {
//     try {
//       final success = await antreanService.batalkanAntrean(
//         layananId,
//         nomorAntrean,
//       );

//       if (success) {
//         print("Antrean $nomorAntrean telah dibatalkan.");
//       }
//     } catch (e) {
//       print("Error saat membatalkan antrean: $e");
//     }
//   }
// }
