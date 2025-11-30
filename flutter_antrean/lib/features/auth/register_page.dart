import 'package:antrean_poliklinik/features/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final alamatController = TextEditingController();
  final nikController = TextEditingController();
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // ALERT DIALOG SEPERTI LOGIN
  // ============================================================
  Future<void> showAlert(String title, String message, {bool success = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.blue : Colors.red,
                size: 58,
              ),
              const SizedBox(height: 15),

              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.blue.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: success ? Colors.blue : Colors.red,
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

  // ============================================================
  // FUNGSI REGISTER
  // ============================================================
  Future<void> register() async {
    // Jalankan validasi
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      // REGISTER AUTH
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = userCred.user!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final kodePasien = "UID_U$timestamp";

      // SIMPAN DATA KE DATABASE
      await FirebaseDatabase.instance.ref("pasien/$kodePasien").set({
        "nama": nameController.text.trim(),
        "email": emailController.text.trim(),
        "no_hp": phoneController.text.trim(),
        "tanggal_lahir": dobController.text.trim(),
        "alamat": alamatController.text.trim(),
        "nik": nikController.text.trim(),
        "uid": uid,
      });

      // ALERT SUKSES
      await showAlert("Berhasil", "Akun berhasil dibuat!", success: true);

      Navigator.pop(context); // kembali ke login
    } catch (e) {
      await showAlert("Gagal", e.toString());
    }
  }

  // ============================================================
  // TOGGLE PASSWORD
  // ============================================================
  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER TETAP / FIX
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
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
                        'Akun Baru',
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
            ),

            // JARAK ANTARA HEADER DAN FORM
            const SizedBox(height: 10),

            // =========================
            // FORM SCROLLABLE
            // =========================
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FORM INPUT
                        buildLabel("Nama Lengkap"),
                        buildField(
                          nameController,
                          "Masukkan Nama Lengkap",
                          validator: (v) =>
                              v!.isEmpty ? "Nama tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 10),

                        buildLabel("Password"),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            buildPasswordField(),
                            IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: _toggleObscure,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        buildLabel("Email"),
                        buildField(
                          emailController,
                          "Masukkan Email",
                          inputType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v!.isEmpty) return "Email tidak boleh kosong";
                            final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailReg.hasMatch(v))
                              return "Format email salah";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        buildLabel("Alamat"),
                        buildField(
                          alamatController,
                          "Masukkan Alamat Lengkap",
                          validator: (v) =>
                              v!.isEmpty ? "Alamat wajib diisi" : null,
                        ),
                        const SizedBox(height: 10),

                        buildLabel("NIK"),
                        buildField(
                          nikController,
                          "Masukkan NIK",
                          inputType: TextInputType.number,
                          validator: (v) {
                            if (v!.isEmpty) return "NIK wajib diisi";
                            if (v.length != 16) return "NIK harus 16 angka";
                            if (!RegExp(r'^[0-9]+$').hasMatch(v))
                              return "NIK hanya angka";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        buildLabel("Nomor Telepon"),
                        buildField(
                          phoneController,
                          "Masukkan Nomor Telepon",
                          inputType: TextInputType.phone,
                          validator: (v) {
                            if (v!.isEmpty) return "Nomor HP wajib diisi";
                            if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                              return "Nomor HP hanya angka";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        buildLabel("Tanggal Lahir"),
                        GestureDetector(
                          onTap: pickDate,
                          child: AbsorbPointer(
                            child: buildField(
                              dobController,
                              "Pilih Tanggal Lahir",
                              validator: (v) {
                                if (v!.isEmpty)
                                  return "Tanggal lahir wajib diisi";
                                final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                                if (!reg.hasMatch(v))
                                  return "Format tanggal tidak valid";
                                return null;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // masuk
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                _slideTo(
                                  const LoginScreen(userType: UserType.Pasien),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Sudah punya akun?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Color(0xFF2B6BFF),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // LINK MASUK
                        // Center(
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       const Text("Sudah punya Akun? "),
                        //       GestureDetector(
                        //         onTap: () => Navigator.pop(context),
                        //         child: const Text(
                        //           "Masuk",
                        //           style: TextStyle(
                        //             color: Color(0xFF2B6BFF),
                        //             fontWeight: FontWeight.w700,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, bottom: 15),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(
                  fontSize: 16,
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

  // ============================================================
  // WIDGET REUSABLE
  // ============================================================
  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String hint, {
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFF256EFF)),
        ),
      ),
    );
  }

  // logic password field
  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscure,
      validator: (v) {
        if (v!.isEmpty) return "Password wajib diisi";
        if (v.length < 8) return "Password minimal 8 karakter";
        return null;
      },
      decoration: InputDecoration(
        hintText: "Masukkan Password",
        filled: true,
        fillColor: const Color(0xFFF0F6FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFF256EFF)),
        ),
      ),
    );
  }

  // function untuk menambahkan pick date kalender
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Pilih Tanggal Lahir",
      cancelText: "Batal",
      confirmText: "Pilih",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2B6BFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        dobController.text =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      });
    }
  }

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
