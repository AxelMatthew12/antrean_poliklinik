import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordManagement extends StatefulWidget {
  const PasswordManagement({super.key});

  @override
  State<PasswordManagement> createState() => _PasswordManagementState();
}

class _PasswordManagementState extends State<PasswordManagement> {
  final TextEditingController currentPassC = TextEditingController();
  final TextEditingController newPassC = TextEditingController();
  final TextEditingController confirmPassC = TextEditingController();

  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  // =========================================================
  // 🔵 UPDATE PASSWORD DENGAN FIREBASE AUTH
  // =========================================================
  Future<void> updatePassword() async {
    final currentPass = currentPassC.text.trim();
    final newPass = newPassC.text.trim();
    final confirmPass = confirmPassC.text.trim();

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password baru dan konfirmasi tidak sama."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User tidak ditemukan."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 1️⃣ RE-AUTHENTICATION
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPass,
      );

      await user.reauthenticateWithCredential(cred);

      // 2️⃣ UPDATE PASSWORD
      await user.updatePassword(newPass);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password berhasil diperbarui!"),
          backgroundColor: Colors.blue,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengubah password: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // 🔵 PASSWORD FIELD WIDGET
  // =========================================================
  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    Widget? extraWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !obscure,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),

        if (extraWidget != null) ...[
          const SizedBox(height: 5),
          extraWidget,
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // =========================================================
  // 🔵 UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF256EFF),
                      size: 26,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Manajer Password",
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF256EFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 30),

              // Password lama
              passwordField(
                label: "Password Saat Ini",
                controller: currentPassC,
                obscure: showCurrent,
                onToggle: () => setState(() => showCurrent = !showCurrent),
                extraWidget: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF256EFF),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Password baru
              passwordField(
                label: "Password Baru",
                controller: newPassC,
                obscure: showNew,
                onToggle: () => setState(() => showNew = !showNew),
              ),

              // Konfirmasi password
              passwordField(
                label: "Konfirmasi Password Baru",
                controller: confirmPassC,
                obscure: showConfirm,
                onToggle: () => setState(() => showConfirm = !showConfirm),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: updatePassword,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF256EFF),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Ubah Password",
                    style: TextStyle(
                      color: Color(0xFF256EFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
