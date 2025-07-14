import 'package:flutter/material.dart';
import 'package:v2g_app/src/features/authentication/screens/otp/otp_email.dart';
import 'package:v2g_app/src/features/authentication/screens/otp/otp_phone.dart';

class SysOpForgot extends StatefulWidget {
  const SysOpForgot({super.key});

  @override
  _SysOpForgotState createState() => _SysOpForgotState();
}

class _SysOpForgotState extends State<SysOpForgot> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Recover Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Choose an Option to Recover Your Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Email Input Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Email',
              ),
            ),
            const SizedBox(height: 20),

            // Send OTP via Email Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
              onPressed: () {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtpEmail(email: email)),
                  );
                } else {
                  showError("Please enter an email.");
                }
              },
              child: const Text("Send OTP via Email", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),
            const Text('OR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 20),

            // Phone Number Input Field
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Phone Number',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
              onPressed: () {
                String phone = phoneController.text.trim();
                if (phone.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtpPhone(phoneNumber: phone)),
                  );
                } else {
                  showError("Please enter a phone number.");
                }
              },
              child: const Text("Send OTP via Phone", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}