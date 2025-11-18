import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:antrean_poliklinik/features/caller/caller_page.dart';
import 'package:antrean_poliklinik/features/caller/pasien_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  // -------------------------------------------------------
  // ALERT DENGAN DESAIN BAGUS + BISA AWAIT
  // -------------------------------------------------------
  Future<void> showAlert(String title, String message) {
    bool isSuccess = title.toLowerCase().contains("berhasil");

    IconData icon = isSuccess ? Icons.check_circle : Icons.error;
    Color iconColor = isSuccess ? Colors.green : Colors.red;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 58),
              const SizedBox(height: 15),

              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  // -------------------------------------------------------
  // LOGIN LOGIC
  // -------------------------------------------------------
  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        // TUNGGU USER MENEKAN OK
        await showAlert("Login Berhasil", "Selamat Datang!");

        // Lanjut cek role
        checkRole(user.email!);
      }
    } on FirebaseAuthException {
      String message = "Email dan Password Salah";

      await showAlert("Login Gagal", message);
    }
  }

  // -------------------------------------------------------
  // CEK ROLE PETUGAS / USER
  // -------------------------------------------------------
  void checkRole(String email) async {
    final refPetugas = FirebaseDatabase.instance.ref("petugas");
    final refPasien = FirebaseDatabase.instance.ref("pasien");

    // ===============================
    // CEK ROLE PETUGAS
    // ===============================
    final snapPetugas = await refPetugas.get();

    if (snapPetugas.exists) {
      Map dataPetugas = snapPetugas.value as Map;

      for (var value in dataPetugas.values) {
        if (value['email'] == email) {
          // LOGIN PETUGAS
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallerPage(
                uid: value['uid'],
                nama: value['nama'],
                loketID: value['loket_id'],
                password: null,
              ),
            ),
          );
          return;
        }
      }
    }

    // ===============================
    // CEK ROLE PASIEN
    // ===============================
    final snapPasien = await refPasien.get();

    if (snapPasien.exists) {
      Map dataPasien = snapPasien.value as Map;

      for (var value in dataPasien.values) {
        if (value['email'] == email) {
          // LOGIN PASIEN
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PasienPage(
                uid: value['uid'],
                nama: value['nama'],
                email: value['email'],
                nik: value['nik'],
                noHP: value['no_hp'],
                alamat: value['alamat'],
                tanggalLahir: value['tanggal_lahir'],
              ),
            ),
          );
          return;
        }
      }
    }

    // ===============================
    // TIDAK DITEMUKAN DI PETUGAS/PASIEN
    // ===============================
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  // -------------------------------------------------------
  // UI LOGIN
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 18.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF2B6BFF),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Hello!',
                          style: TextStyle(
                            color: Color(0xFF2B6BFF),
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 10),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Color(0xFF2B6BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 28),

                // FORM LOGIN
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EMAIL
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailReg.hasMatch(v.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Masukkan Email',
                          filled: true,
                          fillColor: const Color(0xFFF0F6FF),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (v.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Masukkan Password',
                              filled: true,
                              fillColor: const Color(0xFFF0F6FF),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          // EYE BUTTON
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: IconButton(
                              splashRadius: 20,
                              onPressed: _toggleObscure,
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forget Password',
                            style: TextStyle(
                              color: Color(0xFF2B6BFF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 6,
                            backgroundColor: const Color(0xFF2B6BFF),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


