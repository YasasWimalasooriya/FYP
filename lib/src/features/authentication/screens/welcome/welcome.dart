import 'package:flutter/material.dart';
import 'package:v2g_app/src/features/authentication/screens/signup/signup_selection.dart';
import '../login/login_selection.dart';
import 'package:v2g_app/services/blockchain_service.dart';

class Intropage extends StatelessWidget {
  const Intropage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset(
                    'assets/images/image.png',
                    height: 240,
                  ),
                ),
                const Text("POWER SYNC", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Developed by Faculty of Engineering, USJP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const Text("In Collaboration with CEB", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 40),

                /// Test Blockchain Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () async {
                    try {
                      final blockchain = BlockchainService();
                      await blockchain.init();
                      String tokenName = await blockchain.getTokenName();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Smart Contract Response"),
                          content: Text("Token Name: $tokenName"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Error"),
                          content: Text("Failed to connect to Sepolia blockchain:\n$e"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text("Test Blockchain Connection", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),

                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => login_selection())),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Center(
                        child: Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupSelection())),
                  child: const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Center(
                      child: Text(
                        'New User? Click to register now!',
                        style: TextStyle(color: Colors.black, fontSize: 16, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}