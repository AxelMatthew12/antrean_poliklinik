import 'package:antrean_poliklinik/features/auth/greeting_page.dart';
import 'package:antrean_poliklinik/features/auth/welcome_page.dart';
import 'package:antrean_poliklinik/features/caller/controllers/CallerController.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';
import 'package:antrean_poliklinik/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final kios = KiosController();
  final caller = CallerController();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antrean Poliklinik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      // initialRoute: '/welcome',
      initialRoute: '/greeting',

      routes: {
        '/greeting': (_) => const GreetingPage(),
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const WelcomeScreen(), // kamu boleh samakan
      },
    );
  }
}
