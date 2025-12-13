class LoginService {
  void validateLogin(String email, String password) {
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    if (!email.contains('@')) {
      throw Exception('Format email tidak valid');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (password.length < 6) {
      throw Exception('Password terlalu pendek');
    }
  }
}
