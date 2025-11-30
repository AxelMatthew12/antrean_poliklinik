import 'package:flutter/material.dart';

class AnimatedLoginHeader extends StatefulWidget {
  const AnimatedLoginHeader({super.key});

  @override
  State<AnimatedLoginHeader> createState() => _AnimatedLoginHeaderState();
}

class _AnimatedLoginHeaderState extends State<AnimatedLoginHeader>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late Animation<Offset> logoSlide;

  late AnimationController lineController;
  late Animation<double> lineOpacity;

  late AnimationController textController;
  late Animation<double> textOpacity;
  late Animation<Offset> textSlide;

  @override
  void initState() {
    super.initState();

    // LOGO
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    logoSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.22, 0), // posisi ideal mendekati garis
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeInOut));

    // GARIS
    lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    lineOpacity = Tween<double>(begin: 0, end: 1).animate(lineController);

    // TEKS
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 570),
    );

    textOpacity = Tween<double>(begin: 0, end: 1).animate(textController);

    textSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: textController, curve: Curves.easeOut));

    // Jalankan animasi berurutan
    logoController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      lineController.forward();

      await Future.delayed(const Duration(milliseconds: 200));
      textController.forward();
    });
  }

  @override
  void dispose() {
    logoController.dispose();
    lineController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LOGO
            SlideTransition(
              position: logoSlide,
              child: Image.asset(
                'assets/images/logo_klik_antri_light.png',
                width: 80,
                height: 80,
              ),
            ),

            const SizedBox(width: 1),

            // GARIS
            FadeTransition(
              opacity: lineOpacity,
              child: Container(
                width: 2,
                height: 70,
                color: const Color(0xFF2B6BFF),
              ),
            ),

            const SizedBox(width: 15),

            // TEKS
            FadeTransition(
              opacity: textOpacity,
              child: SlideTransition(
                position: textSlide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Selamat",
                      style: TextStyle(
                        color: Color(0xFF2B6BFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Datang Di",
                      style: TextStyle(
                        color: Color(0xFF2B6BFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Klik Antri",
                      style: TextStyle(
                        color: Color(0xFF2B6BFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
