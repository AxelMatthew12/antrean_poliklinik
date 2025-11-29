import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailProfile extends StatefulWidget {
  final Map? userData;

  const DetailProfile({super.key, this.userData});

  @override
  State<DetailProfile> createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> {
  final db = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;

  late TextEditingController namaC;
  late TextEditingController nikC;
  late TextEditingController telpC;
  late TextEditingController emailC;
  late TextEditingController tglLahirC;
  late TextEditingController alamatC;

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController(text: widget.userData?["nama"] ?? "");
    nikC = TextEditingController(text: widget.userData?["nik"] ?? "");
    telpC = TextEditingController(text: widget.userData?["no_hp"] ?? "");
    emailC = TextEditingController(text: widget.userData?["email"] ?? "");
    tglLahirC =
        TextEditingController(text: widget.userData?["tanggal_lahir"] ?? "");
    alamatC = TextEditingController(text: widget.userData?["alamat"] ?? "");
  }

  // ============================================================
  // 🔵 DATE PICKER TANGGAL LAHIR
  // ============================================================
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(tglLahirC.text) ??
          DateTime(2000, 1, 1), // default tanggal
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF256EFF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        tglLahirC.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Input tanggal (readOnly + icon kalender)
  Widget _dateInput(TextEditingController controller) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon:
                const Icon(Icons.calendar_month, color: Color(0xFF256EFF)),
            hintText: "YYYY-MM-DD",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide:
                  const BorderSide(color: Color(0xFF256EFF), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide:
                  const BorderSide(color: Color(0xFF256EFF), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔵 POPUP SUKSES (UI PREMIUM)
  // ============================================================
  Future<void> showSuccessPopup(Map updatedData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF256EFF),
                  size: 65,
                ),
                const SizedBox(height: 22),
                const Text(
                  "Berhasil melakukan\nperubahan data",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF256EFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol
                SizedBox(
                  width: 180,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, updatedData);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF256EFF),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF256EFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔵 UPDATE PROFILE FUNCTION
  // ============================================================
  Future<void> _updateProfile() async {
    final uid = auth.currentUser!.uid;
    final pasienRef = db.child("pasien");

    final data = {
      "nama": namaC.text.trim(),
      "nik": nikC.text.trim(),
      "no_hp": telpC.text.trim(),
      "email": emailC.text.trim(),
      "tanggal_lahir": tglLahirC.text.trim(),
      "alamat": alamatC.text.trim(),
      "uid": uid,
    };

    final snapshot = await pasienRef.get();
    String? targetKey;

    for (var child in snapshot.children) {
      final childData = Map<String, dynamic>.from(child.value as Map);

      if (childData["uid"] == uid) {
        targetKey = child.key;
        break;
      }
    }

    if (targetKey == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data profil tidak ditemukan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await pasienRef.child(targetKey).update(data);

    if (!mounted) return;
    await showSuccessPopup(data);
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF256EFF),
                    ),
                  ),
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF256EFF),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 10),

              // FOTO PROFIL
              CircleAvatar(
                radius: 58,
                backgroundImage: widget.userData?["foto"] != null
                    ? NetworkImage(widget.userData!["foto"])
                    : const AssetImage("assets/profile.jpeg")
                        as ImageProvider,
              ),

              const SizedBox(height: 26),

              _label("Nama"),
              _input(namaC),

              _label("NIK"),
              _input(nikC),

              _label("Nomor Telp"),
              _input(telpC),

              _label("Email"),
              _input(emailC),

              _label("Tanggal Lahir"),
              _dateInput(tglLahirC),   // ← DIGANTI DATE PICKER

              _label("Alamat"),
              _input(alamatC),

              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                height: 50,
                child: OutlinedButton(
                  onPressed: _updateProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF256EFF), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
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

  // Label Text
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Input Field (default)
  Widget _input(TextEditingController c, {String? hint}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide:
              const BorderSide(color: Color(0xFF256EFF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide:
              const BorderSide(color: Color(0xFF256EFF), width: 2),
        ),
      ),
    );
  }
}
