import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthRepository {
  Future<User?> login(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<Map?> getUserRole(String email) async {
    final refPetugas = FirebaseDatabase.instance.ref("petugas");
    final refPasien = FirebaseDatabase.instance.ref("pasien");

    final snapPetugas = await refPetugas.get();
    if (snapPetugas.exists) {
      final data = snapPetugas.value as Map;
      for (var value in data.values) {
        if (value['email'] == email) {
          return {'role': 'petugas', 'data': value};
        }
      }
    }

    final snapPasien = await refPasien.get();
    if (snapPasien.exists) {
      final data = snapPasien.value as Map;
      for (var value in data.values) {
        if (value['email'] == email) {
          return {'role': 'pasien', 'data': value};
        }
      }
    }

    return null;
  }
}
