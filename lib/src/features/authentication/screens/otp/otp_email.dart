import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpEmail extends StatefulWidget {
  final String email;

  const OtpEmail({super.key, required this.email});

  @override
  _OtpEmailState createState() => _OtpEmailState();
}

class _OtpEmailState extends State<OtpEmail> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  // Function to send OTP to email
  Future<void> sendOtp() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      showError("Error sending OTP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Verify Email OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your email",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter OTP',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
              onPressed: () {
                showError("Verify the password reset link in your email.");
              },
              child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
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