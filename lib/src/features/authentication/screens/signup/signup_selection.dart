import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:v2g_app/src/features/authentication/screens/signup/sys_operator_signup.dart';
import 'ev_owner_signup.dart';

class SignupSelection extends StatelessWidget {
  const SignupSelection({super.key});

  Future<void> _askMetaMaskWallet(BuildContext context) async {
    final bool? hasWallet = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MetaMask Wallet'),
        content: const Text('Do you have a MetaMask wallet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text('No. Create one'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (hasWallet == true) {
      // Navigate to EV Owner Signup
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EvOwnerSignup()),
      );
    } else if (hasWallet == false) {
      // Open MetaMask website
      final url = Uri.parse('https://metamask.io/');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open MetaMask website')),
        );
      }
    }
    // if null (dialog dismissed), do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text(
          'Choose Your Category',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _askMetaMaskWallet(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Center(
                        child: Text(
                          'Sign up as Electric Vehicle Owner',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const sysOpSignup()),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Center(
                        child: Text(
                          'Sign up as System Operator',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
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