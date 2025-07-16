import 'package:flutter/material.dart';
import '../../../../services/blockchain_service.dart';
import '../../authentication/screens/welcome/welcome.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  late Future<bool> initFuture;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    initFuture = getData();
  }

  Future<bool> getData() async {
    return await BlockchainService().init();
  }

  void _navigateToIntroPage() {
    if (!hasNavigated) {
      hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Intropage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToIntroPage();
                });
                return const SizedBox(); // avoid rebuilding the screen
              } else {
                return const Text('Blockchain initialization failed');
              }
            } else {
              return const Text('Unexpected error');
            }
          },
        ),
      ),
    );
  }
}
