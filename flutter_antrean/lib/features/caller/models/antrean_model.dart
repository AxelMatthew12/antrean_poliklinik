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
  final String poli;       
  final String status;     
  final String waktu;       
  final String pasienUID;
  final String layananID;  // <── tambahan baru
  
  AntreanModel({
    required this.nomor,
    required this.poli,
    required this.status,
    required this.waktu,
    required this.pasienUID,
    required this.layananID,  // <── wajib
  });

  factory AntreanModel.fromMap(String nomor, Map data) {
    return AntreanModel(
      nomor: nomor,
      poli: data['poli'] ?? "",                 // <── ini ambil NAMA POLI
      status: data['status'] ?? "",
      waktu: data['waktu_ambil'] ?? "",
      pasienUID: data['pasien_uid'] ?? "",
      layananID: data['layanan_id'] ?? "",      // <── ini ambil ID POLI
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nomor": nomor,
      "poli": poli,
      "status": status,
      "waktu_ambil": waktu,
      "pasien_uid": pasienUID,
      "layanan_id": layananID,                  // <── simpan juga
    };
  }
}
