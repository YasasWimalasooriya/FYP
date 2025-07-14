import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/screens/Dashboard/dashboard.dart';
import '../forgot_password/ev_owner_forgot.dart';

class evOwnerLogin extends StatefulWidget {
  evOwnerLogin({super.key});

  @override
  State<evOwnerLogin> createState() => _evOwnerLogin ();
}

class _evOwnerLogin extends State<evOwnerLogin> {
  // Define TextEditingControllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to handle login
  Future<void> loginUser() async {
    try {
      // Get email and password
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      // Validate email and password
      if (email.isEmpty || password.isEmpty) {
        showPopupDialog(context, 'Please enter both email and password.', 'Error!');
        return;
      }

      // Sign in the user using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If login is successful, navigate to the Dashboard page
      if (userCredential.user != null) {
        // Navigate to Dashboard after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => evDash(),  // Navigate to the Dashboard page
          ),
        );
      }
    } catch (e) {
      // If there's an error (e.g., wrong credentials), show error message
      showPopupDialog(context, 'Login failed. Please check your credentials and try again.', 'Error!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text('Electric Vehicle Owner Login',
        style: TextStyle(
        color: Colors.white,)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email TextField
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'User Name or Email',
              ),
            ),
            const SizedBox(height: 50),

            // Password TextField
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
            const SizedBox(height: 50),

            // Login Button
            GestureDetector(
              onTap: loginUser, // Call loginUser when the button is tapped
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
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

            // Forgot Password Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EvOwnerForgot(),
                  ),
                );
              },
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

  // Function to show popup dialog (error messages)
  void showPopupDialog(BuildContext context, String message, String title) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}