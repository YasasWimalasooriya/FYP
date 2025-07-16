import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:v2g_app/firebase_options.dart';
import 'package:v2g_app/src/features/SplashScreen/ui/SplashScreen.dart';
import 'package:v2g_app/src/features/authentication/screens/welcome/welcome.dart';
import 'package:v2g_app/services/blockchain_service.dart';
import 'src/features/core/screens/purchase_energy_tokens/purchase_energy_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize blockchain
  //await BlockchainService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V2G Energy App',
      home: Splashscreen(),

      //const Intropage(),

      // ✅ Define your named routes here
      // routes: {
      //   '/chargeVehicle': (context) => const PurchaseEnergyTokensPage(),
      //   // You can add more routes here if needed
      // },
    );
  }
}