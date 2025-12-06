import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  bool notifUmum = true;
  bool notifSuara = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// ==========================================================
  /// 🔵 LOAD SETTING dari SharedPreferences
  /// ==========================================================
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        notifUmum = prefs.getBool("notif_umum") ?? true;
        notifSuara = prefs.getBool("notif_suara") ?? true;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR load settings: $e");
      setState(() => isLoading = false);
    }
  }

  /// ==========================================================
  /// 🔵 SIMPAN SETTING
  /// ==========================================================
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("notif_umum", notifUmum);
      await prefs.setBool("notif_suara", notifSuara);
    } catch (e) {
      print("ERROR save settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF256EFF),
                            size: 24,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Pengaturan Notifikasi",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF256EFF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 40),

                    /// ===== NOTIFIKASI UMUM =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifikasi Umum",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: notifUmum,
                          onChanged: (val) async {
                            setState(() => notifUmum = val);
                            await _saveSettings();
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF256EFF),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ===== SUARA =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Suara",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: notifSuara,
                          onChanged: (val) async {
                            setState(() => notifSuara = val);
                            await _saveSettings();
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF256EFF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
