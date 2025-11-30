import 'package:antrean_poliklinik/features/auth/animated_login_header.dart';
import 'package:antrean_poliklinik/features/auth/register_page.dart';
import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:antrean_poliklinik/features/kios/home/homepage.dart';
import 'package:antrean_poliklinik/features/caller/caller_homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// UserType
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

  // Alert Login dan sign up berhasil / gagal
  Future<void> showAlert(String title, String message) {
    bool isSuccess = title.toLowerCase().contains("berhasil");

    IconData icon = isSuccess ? Icons.check_circle : Icons.error;
    Color iconColor = isSuccess ? Colors.blue : Colors.red;

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
                  color: isSuccess ? Colors.blue.shade700 : Colors.red.shade700,
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
                    backgroundColor: isSuccess ? Colors.blue : Colors.red,
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

    // ===============================
    // CEK ROLE PASIEN
    // ===============================
    final snapPasien = await refPasien.get();

    if (snapPasien.exists) {
      Map dataPasien = snapPasien.value as Map;

      for (var value in dataPasien.values) {
        if (value['email'] == email) {
          // KIRIM DATA PASIEN KE HOMEPAGE
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(userData: value)),
          );
          return;
        }
      }
    }

    // ===============================
    // JIKA TIDAK DITEMUKAN
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
        child: Stack(
          children: [
            // ====== FORM DAN KONTEN SCROLLABLE ======
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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

                  // FORM
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
                            fontSize: 16,
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
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                color: Color(0xFF256EFF),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
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
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF256EFF),
                                  ),
                                ),
                              ),
                            ),

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
                              'Lupa Password?',
                              style: TextStyle(
                                color: Color(0xFF2B6BFF),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // REGISTER BUTTON (hanya pasien)
                        if (widget.userType == UserType.Pasien)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  _slideTo(const RegisterScreen()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Belum punya akun?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Daftar',
                                    style: TextStyle(
                                      color: Color(0xFF2B6BFF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(
                          height: 70,
                        ), // Agar tidak ketutup tombol bawah
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ====== TOMBOL MASUK DI BAWAH ======
          ],
        ),
      ),
      // === TOMBOL DI BAWAH ===
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, bottom: 30),
          child: SizedBox(
            height: 56,
            width: double.infinity,
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

  // fungsi untuk transisi halaman
  // ===== FUNGSI TRANSISI SLIDE =====
  Route _slideTo(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Halaman masuk
        final slideIn =
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
            );

        // Halaman sebelumnya geser keluar
        final slideOut =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.25, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutQuart,
              ),
            );

        return Stack(
          children: [
            SlideTransition(
              position: slideOut,
              child: secondaryAnimation.status != AnimationStatus.dismissed
                  ? child
                  : const SizedBox(),
            ),
            SlideTransition(position: slideIn, child: child),
          ],
        );
      },
    );
  }
}
