import 'package:antrean_poliklinik/features/auth/animated_login_header.dart';
import 'package:antrean_poliklinik/features/auth/register_page.dart';
import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:antrean_poliklinik/features/kios/home/homepage.dart';
import 'package:antrean_poliklinik/features/caller/home/caller_homepage.dart';
import 'package:flutter/material.dart';

import 'login_service.dart';
import 'auth_repository.dart';

enum UserType { Petugas, Pasien }

class LoginScreen extends StatefulWidget {
  final UserType userType;
  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  final LoginService _loginService = LoginService();
  final AuthRepository _authRepository = AuthRepository();

  // ================= ALERT =================
  Future<void> showAlert(String title, String message) async {
    final isSuccess = title.toLowerCase().contains("berhasil");
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
                color: isSuccess ? const Color(0xFF2B6BFF) : Colors.red,
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
                    backgroundColor: isSuccess
                        ? const Color(0xFF2B6BFF)
                        : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  // ================= SUBMIT LOGIN =================
  Future<void> _submit() async {
    try {
      // 1️⃣ VALIDASI INPUT
      _loginService.validateLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2️⃣ LOGIN
      final user = await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        await showAlert("Login Gagal", "User tidak ditemukan");
        return;
      }

      // 3️⃣ CEK ROLE
      final result = await _authRepository.getUserRole(user.email ?? '');

      await showAlert("Login Berhasil", "Selamat Datang!");

      // 4️⃣ NAVIGASI
      _handleNavigation(result);
    } catch (e) {
      await showAlert(
        "Login Gagal",
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ================= NAVIGASI =================
  void _handleNavigation(Map? result) {
    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return;
    }

    final role = result['role'];
    final data = result['data'];

    if (role == 'petugas') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CallerPage(
            nama: data['nama'],
            loketID: data['loket_id'],
            email: data['email'],
            uid: data['uid'],
          ),
        ),
      );
    } else if (role == 'pasien') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userData: data)),
      );
    }
  }

  // ================= UI =================
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
                            style: TextStyle(color: Color(0xFF2B6BFF)),
                          ),
                        ),
                      ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
