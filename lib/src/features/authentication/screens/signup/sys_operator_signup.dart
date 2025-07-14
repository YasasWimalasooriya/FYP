import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../system/screens/Dashboard/dashboard.dart';

class sysOpSignup extends StatefulWidget {
  const sysOpSignup({super.key});

  @override
  State<sysOpSignup> createState() => _sysOpSignup();
}

class _sysOpSignup extends State<sysOpSignup> {
  // Controllers for user input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false; // Loading state

  // Function to register System Operator
  Future<void> _registerSystemOperator() async {
    if (passwordController.text.isEmpty || rePasswordController.text.isEmpty) {
      _showPopupDialog('Password fields cannot be empty!', 'Error!');
      return;
    }

    if (passwordController.text != rePasswordController.text) {
      _showPopupDialog('Passwords do not match! Please try again.', 'Error!');
      return;
    }

    setState(() => isLoading = true); // Show loading indicator

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid; // Get UID

      // Store System Operator data in Firestore
      await _firestore.collection('system_operators').doc(uid).set({
        'name': nameController.text.trim(),
        'registrationNumber': regNoController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showPopupDialog('Registration successful!', 'Success', isSuccess: true);

    } catch (e) {
      _showPopupDialog('Registration failed. Error: $e', 'Error!');
    }

    setState(() => isLoading = false); // Hide loading indicator
  }

  // Function to show popup dialog for messages
  void _showPopupDialog(String message, String title, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Get.offAll(() => SystemOperatorDashboard()); // Navigate to Dashboard
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text('System Operator Sign Up',
            style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Details Below',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Full Name',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: regNoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Registration Number',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: rePasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Re-Enter Password',
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _registerSystemOperator, // Call registration function
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'NEXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
