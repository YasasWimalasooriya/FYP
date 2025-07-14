import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../authentication/screens/welcome/welcome.dart';

class SystemOperatorProfile extends StatefulWidget {
  const SystemOperatorProfile({super.key});

  @override
  _SystemOperatorProfileState createState() => _SystemOperatorProfileState();
}

class _SystemOperatorProfileState extends State<SystemOperatorProfile> {
  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('system_operators').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            operatorNameController.text = userDoc['name'] ?? '';
            registrationNumberController.text = userDoc['registrationNumber'] ?? '';
            emailController.text = userDoc['email'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("System Operator Profile",
            style: TextStyle(color: Colors.white),
    ),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Intropage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile Clicked')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900], // Dark green button
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Operator Name Field
            _buildTextField(operatorNameController, "Operator Name"),
            const SizedBox(height: 15),

            // Registration Number Field
            _buildTextField(registrationNumberController, "Registration Number"),
            const SizedBox(height: 15),

            // Email Field
            _buildTextField(emailController, "Email"),
          ],
        ),
      ),
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}