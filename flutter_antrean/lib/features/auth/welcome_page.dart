import 'package:antrean_poliklinik/features/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:antrean_poliklinik/features/auth/login_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> fadeTitle;
  late Animation<double> fadeLogo;
  late Animation<double> scaleLogo;

  // === Button Highlight State ===
  int activeButton = -1; // -1 = none, 0 = login, 1 = daftar

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    fadeLogo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    scaleLogo = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    fadeTitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================
  // WIDGET TOMBOL + HIGHLIGHT
  // ============================
  Widget _buildAnimatedButton({
    required String text,
    required bool isPrimary,
    required int index,
    required VoidCallback onPressed,
  }) {
    bool isActive = activeButton == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: isActive
            ? (isPrimary ? const Color(0xFF1F57D6) : const Color(0xFFD2DBFF))
            : (isPrimary ? const Color(0xFF2B6BFF) : const Color(0xFFE1E9FF)),
        borderRadius: BorderRadius.circular(50),
        border: isActive
            ? Border.all(color: Colors.blue.shade800, width: 1.6)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTapDown: (_) => setState(() => activeButton = index),
        onTapCancel: () => setState(() => activeButton = -1),
        onTap: () {
          setState(() => activeButton = index);
          Future.delayed(const Duration(milliseconds: 150), () {
            setState(() => activeButton = -1);
            onPressed();
          });
        },
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isActive ? 1.05 : 1.0,
            curve: Curves.easeOut,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: isPrimary ? Colors.white : const Color(0xFF2B6BFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // MAIN UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),

                              FadeTransition(
                                opacity: fadeLogo,
                                child: ScaleTransition(
                                  scale: scaleLogo,
                                  child: SizedBox(
                                    width: 138,
                                    height: 138,
                                    child: Image.asset(
                                      'assets/images/logo_klik_antri_light.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

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
                                            color: Color(0xFF2B6BFF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Antri",
                                          style: TextStyle(
                                            fontSize: 26,
                                            color: Color(0xFF2B6BFF),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              FadeTransition(
                                opacity: fadeTitle,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    "Aplikasi Antrean Poliklinik",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2B6BFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Antri Klik memudahkan pengambilan antrean rumah sakit secara online. "
                                  "Cepat, praktis, dan tanpa ribet datang tepat waktu tanpa menunggu lama.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2B6BFF),
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ============================
            // TOMBOL LOGIN (MODIFIKASI)
            // ============================
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 60, bottom: 8),
              child: _buildAnimatedButton(
                text: "Masuk",
                isPrimary: true,
                index: 0,
                onPressed: () {
                  Navigator.of(context).push(
                    _slideTo(const LoginScreen(userType: UserType.Pasien)),
                  );
                },
              ),
            ),

            // ============================
            // TOMBOL DAFTAR (MODIFIKASI)
            // ============================
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 60, bottom: 30),
              child: _buildAnimatedButton(
                text: "Daftar",
                isPrimary: false,
                index: 1,
                onPressed: () {
                  Navigator.push(context, _slideTo(const RegisterScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
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
