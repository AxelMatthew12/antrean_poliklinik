import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:flutter/material.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> fadeLogo;
  late Animation<double> scaleLogo;

  late Animation<double> fadeTitle;
  late Animation<double> fadeDesc;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // ===== ANIMASI LOGO =====
    fadeLogo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    scaleLogo = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // ===== ANIMASI TITLE =====
    fadeTitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
      ),
    );

    // ===== ANIMASI DESKRIPSI =====
    fadeDesc = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF256EFF),

      // ===== TOMBOL SELANJUTNYA DI BAGIAN BAWAH =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60, bottom: 30),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              "Selanjutnya",
              style: TextStyle(fontSize: 18, color: Color(0xFF256EFF)),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ======================
                // LOGO + ANIMASI
                // ======================
                FadeTransition(
                  opacity: fadeLogo,
                  child: ScaleTransition(
                    scale: scaleLogo,
                    child: SizedBox(
                      width: 138,
                      height: 138,
                      child: Image.asset(
                        'assets/images/logo_klik_antri_dark.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ======================
                // TITLE + ANIMASI
                // ======================
                FadeTransition(
                  opacity: fadeTitle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "klik ",
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "Antri",
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Highlight aplikasi
                FadeTransition(
                  opacity: fadeTitle,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      "Aplikasi Antrean Poliklinik",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // ======================
                // DESKRIPSI + ANIMASI
                // ======================
                FadeTransition(
                  opacity: fadeDesc,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      "Antri Klik memudahkan pengambilan antrean rumah sakit secara online. "
                      "Cepat, praktis, dan tanpa ribet datang tepat waktu tanpa menunggu lama.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== TRANSISI KE HALAMAN SELANJUTNYA =====
  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const WelcomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn =
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
            );

        final slideOut =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.25, 0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutQuart,
              ),
            );

        return Stack(
          children: [
            SlideTransition(position: slideOut, child: child),
            SlideTransition(position: slideIn, child: child),
          ],
        );
      },
    );
  }
}
