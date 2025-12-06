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
    tglLahirC = TextEditingController(text: widget.userData?["tanggal_lahir"] ?? "");
    alamatC = TextEditingController(text: widget.userData?["alamat"] ?? "");
  }

  Future<void> _reloadUserData() async {
    final uid = auth.currentUser!.uid;
    final pasienRef = db.child("pasien");
    final snapshot = await pasienRef.get();
    for (var child in snapshot.children) {
      final d = Map<String, dynamic>.from(child.value as Map);

      if (d["uid"] == uid) {
        setState(() {
          namaC.text = d["nama"] ?? "";
          nikC.text = d["nik"] ?? "";
          telpC.text = d["no_hp"] ?? "";
          emailC.text = d["email"] ?? "";
          tglLahirC.text = d["tanggal_lahir"] ?? "";
          alamatC.text = d["alamat"] ?? "";
        });
        break;
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(tglLahirC.text) ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF256EFF)),
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

  Widget _dateInput(TextEditingController controller) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF256EFF)),
            hintText: "YYYY-MM-DD",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(color: Color(0xFF256EFF), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(color: Color(0xFF256EFF), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // POPUP SUKSES
  Future<void> showSuccessPopup(Map updatedData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF256EFF), size: 65),
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

                SizedBox(
                  width: 180,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);      // Tutup popup
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF256EFF), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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

  // ============== UPDATE PROFILE =======================
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data profil tidak ditemukan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await pasienRef.child(targetKey).update(data);
    await showSuccessPopup(data);
    await _reloadUserData();
  }
  // UI
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF256EFF)),
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
                backgroundColor: Colors.blue.shade400,
                child: Text(
                  (namaC.text.isNotEmpty ? namaC.text[0] : "U").toUpperCase(),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
              _dateInput(tglLahirC),
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
  Widget _input(TextEditingController c, {String? hint}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF256EFF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF256EFF), width: 2),
        ),
      ),
    );
  }
}
