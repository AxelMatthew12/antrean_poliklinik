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

  // Performs the password update through Firebase Auth
  Future<void> updatePassword() async {
    final currentPass = currentPassC.text.trim();
    final newPass = newPassC.text.trim();
    final confirmPass = confirmPassC.text.trim();

    if (newPass != confirmPass) {
      _showMessage("Password baru dan konfirmasi tidak sama.", Colors.red);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage("User tidak ditemukan.", Colors.red);
        return;
      }

      // Re-authentication
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPass,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPass);

      _showMessage("Password berhasil diperbarui!", Colors.blue);
      Navigator.pop(context);

    } catch (e) {
      _showMessage("Gagal mengubah password: $e", Colors.red);
    }
  }

  // Shows a Snackbar message
  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  // Password input field component
  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
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
                  obscureText: !visible,
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
                  visible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
              ),
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

  // Main UI
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
              _buildHeader(),

              const SizedBox(height: 30),

              // Current password
              passwordField(
                label: "Password Saat Ini",
                controller: currentPassC,
                visible: showCurrent,
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

              // New password
              passwordField(
                label: "Password Baru",
                controller: newPassC,
                visible: showNew,
                onToggle: () => setState(() => showNew = !showNew),
              ),

              // Confirm password
              passwordField(
                label: "Konfirmasi Password Baru",
                controller: confirmPassC,
                visible: showConfirm,
                onToggle: () => setState(() => showConfirm = !showConfirm),
              ),

              const SizedBox(height: 20),

              // Submit button
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

  // Header layout
  Widget _buildHeader() {
    return Row(
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
    );
  }
}
