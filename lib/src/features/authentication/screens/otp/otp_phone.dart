import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpPhone extends StatefulWidget {
  final String phoneNumber;

  const OtpPhone({super.key, required this.phoneNumber});

  @override
  _OtpPhoneState createState() => _OtpPhoneState();
}

class _OtpPhoneState extends State<OtpPhone> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  // Function to send OTP via SMS
  Future<void> sendOtp() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        showError("Phone verified successfully!");
      },
      verificationFailed: (FirebaseAuthException e) {
        showError("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
        });
        showError("OTP sent to ${widget.phoneNumber}");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Function to verify OTP
  Future<void> verifyOtp() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );
      await auth.signInWithCredential(credential);
      showError("Phone verified successfully!");
    } catch (e) {
      showError("Invalid OTP. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Verify Phone OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your phone",
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
              onPressed: verifyOtp,
              child: const Text("Verify OTP"),
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