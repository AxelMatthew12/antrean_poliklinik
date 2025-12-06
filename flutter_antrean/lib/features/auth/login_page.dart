import 'package:antrean_poliklinik/features/auth/animated_login_header.dart';
import 'package:antrean_poliklinik/features/auth/register_page.dart';
import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:antrean_poliklinik/features/kios/home/homepage.dart';
import 'package:antrean_poliklinik/features/caller/home/caller_homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum UserType { Petugas, Pasien }

class LoginScreen extends StatefulWidget {
  final UserType userType;
  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  Future<void> showAlert(String title, String message) async {
    bool isSuccess = title.toLowerCase().contains("berhasil");
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
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Color(0xFF2B6BFF) : Colors.red,
                size: 58,
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? const Color(0xFF1E40AF)
                      : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Color(0xFF2B6BFF) : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await showAlert("Login Berhasil", "Selamat Datang!");
        checkRole(user.email!);
      }
    } catch (e) {
      await showAlert("Login Gagal", "Email atau password salah");
    }
  }

  void checkRole(String email) async {
    final refPetugas = FirebaseDatabase.instance.ref("petugas");
    final refPasien = FirebaseDatabase.instance.ref("pasien");

    // CEK PETUGAS
    final snapPetugas = await refPetugas.get();
    if (snapPetugas.exists) {
      Map dataPetugas = snapPetugas.value as Map;
      for (var value in dataPetugas.values) {
        if (value['email'] == email) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallerPage(
                nama: value["nama"],
                loketID: value["loket_id"],
                email: value["email"],
                uid: value["uid"],
              ),
            ),
          );
          return;
        }
      }
    }

    // CEK PASIEN
    final snapPasien = await refPasien.get();
    if (snapPasien.exists) {
      Map dataPasien = snapPasien.value as Map;
      for (var value in dataPasien.values) {
        if (value['email'] == email) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(userData: value)),
          );
          return;
        }
      }
    }

    // JIKA TIDAK DITEMUKAN
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF2B6BFF),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Halo!',
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
              const AnimatedLoginHeader(),
              const SizedBox(height: 25),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      validator: (v) =>
                          v!.isEmpty ? "Email tidak boleh kosong" : null,
                      decoration: _inputDecoration("Masukkan Email"),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          validator: (v) =>
                              v!.isEmpty ? "Password tidak boleh kosong" : null,
                          decoration: _inputDecoration("Masukkan Password"),
                        ),
                        IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: _toggleObscure,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (widget.userType == UserType.Pasien)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Belum punya akun? Daftar',
                            style: TextStyle(
                              color: Color(0xFF2B6BFF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, bottom: 30),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Input Decoration Helper
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xFF256EFF)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
