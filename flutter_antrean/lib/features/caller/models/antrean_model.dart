// class AntreanModel {
//   final String nomor;
//   final String poli;
//   final String status;
//   final String waktu;
//   final String pasienUID;

//   // Konstruktor utama
//   AntreanModel({
//     required this.nomor,
//     required this.poli,
//     required this.status,
//     required this.waktu,
//     required this.pasienUID,
//   });

//   // Membuat objek dari Map (dari Firebase)
//   factory AntreanModel.fromMap(String nomor, Map data) {
//     return AntreanModel(
//       nomor: nomor,
//       poli: data['layanan_id'] ?? "",
//       status: data['status'] ?? "",
//       waktu: data['waktu_ambil'] ?? "",
//       pasienUID: data['pasien_uid'] ?? "",
//     );
//   }

//   // Mengubah objek menjadi Map (untuk disimpan ke Firebase)
//   Map<String, dynamic> toMap() {
//     return {
//       "nomor": nomor,
//       "layanan_id": poli,
//       "status": status,
//       "waktu_ambil": waktu,
//       "pasien_uid": pasienUID,
//     };
//   }
// }

class AntreanModel {
  final String nomor;
  final String layananID;
  final String status;
  final String waktu_ambil;
  final String waktu_panggil;
  final String waktu_selesai;
  final String pasienUID;

  AntreanModel({
    required this.nomor,
    required this.layananID,
    required this.status,
    required this.waktu_ambil,
    required this.waktu_panggil,
    required this.waktu_selesai,
    required this.pasienUID,
  });

  factory AntreanModel.fromMap(String nomor, Map data) {
    return AntreanModel(
      nomor: nomor,
      layananID: data['layanan_id'] ?? "",
      status: data['status'] ?? "",
      waktu_ambil: data['waktu_ambil'] ?? "",
      waktu_panggil: data['waktu_panggil'] ?? "",
      waktu_selesai: data['waktu_selesai'] ?? "",
      pasienUID: data['pasien_uid'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nomor": nomor,
      "layanan_id": layananID,
      "status": status,
      "waktu_ambil": waktu_ambil,
      "waktu_panggil": waktu_panggil,
      "waktu_selesai": waktu_selesai,
      "pasien_uid": pasienUID,
    };
  }
}
