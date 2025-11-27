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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Form(
              key: _formKey,
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

                  const SizedBox(height: 20),

                  // FORM INPUT
                  buildLabel("Nama Lengkap"),
                  buildField(
                    nameController,
                    "Masukkan Nama Lengkap",
                    validator: (v) =>
                        v!.isEmpty ? "Nama tidak boleh kosong" : null,
                  ),
                  const SizedBox(height: 20),

                  buildLabel("Password"),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      buildPasswordField(),
                      IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: _toggleObscure,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  buildLabel("Email"),
                  buildField(
                    emailController,
                    "Masukkan Email",
                    inputType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return "Email tidak boleh kosong";
                      final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailReg.hasMatch(v)) return "Format email salah";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  buildLabel("Alamat"),
                  buildField(
                    alamatController,
                    "Masukkan Alamat Lengkap",
                    validator: (v) => v!.isEmpty ? "Alamat wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  buildLabel("Tanggal Lahir"),
                  buildField(
                    dobController,
                    "Masukkan Tanggal Lahir (YYYY-MM-DD)",
                    validator: (v) {
                      if (v!.isEmpty) return "Tanggal lahir wajib diisi";
                      final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                      if (!reg.hasMatch(v))
                        return "Format tanggal harus YYYY-MM-DD";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 6,
                        backgroundColor: const Color(0xFF2B6BFF),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // LINK MASUK
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya Akun? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Masuk",
                            style: TextStyle(
                              color: Color(0xFF2B6BFF),
                              fontWeight: FontWeight.w700,
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
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
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
    );
  }

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
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
