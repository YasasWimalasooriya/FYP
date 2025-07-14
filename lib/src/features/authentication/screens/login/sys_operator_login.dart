import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../forgot_password/sys_op_forgot.dart';
import '../../../system/screens/Dashboard/dashboard.dart';

class sysOpLogin extends StatefulWidget {
  const sysOpLogin({super.key});

  @override
  State<sysOpLogin> createState() => _sysOpLogin();
}

class _sysOpLogin extends State<sysOpLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false; // Loading indicator

  // Function to handle login
  Future<void> _loginSystemOperator() async {
    setState(() => isLoading = true); // Show loading indicator

    try {
      // Authenticate user with Firebase Auth
      print("getting email");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("loginn!!");


      String uid = userCredential.user!.uid;



      // Check if the user exists in the "system_operators" collection
      DocumentSnapshot userDoc = await _firestore.collection('system_operators').doc(uid).get();
      print("loginn!");
      print(uid);
      if (userDoc.exists) {
        print("Pushing");
        // Successful login, navigate to dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SystemOperatorDashboard() // Navigate to the Dashboard page
          ),
        );
      }

      else {
        _showPopupDialog('Access Denied! Not registered as a System Operator.', 'Error!');
        await _auth.signOut(); // Sign out since the user isn't a system operator
      }
    } on FirebaseAuthException catch (e) {
      print("error!"+e.toString());
      _showPopupDialog('Login failed: ${e.message}', 'Error!');
    }

    setState(() => isLoading = false); // Hide loading indicator
  }

  // Function to show popup dialog for error/success messages
  void _showPopupDialog(String message, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
        title: const Text('System Operator Login',
          style: TextStyle(
          color: Colors.white,),
      ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 50),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true, // Obscure the password input
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            const SizedBox(height: 50),

            // Login Button
            GestureDetector(
              onTap: _loginSystemOperator,
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
                      'LOGIN',
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

            // Forgot Password Section
            GestureDetector(
              onTap: () => Get.to(() => const SysOpForgot()),
              child: const Padding(
                padding: EdgeInsets.all(25.0),
                child: Center(
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}