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
      backgroundColor: Color(0xFF040B19),
      body: Center(
        child: FutureBuilder<bool>(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/loading.gif")),
                  const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Please wait...",style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),),
                  )
                ],
              );
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
