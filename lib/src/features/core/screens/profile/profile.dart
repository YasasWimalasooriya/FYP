import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../authentication/screens/welcome/welcome.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fullCapacityController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            nameController.text = userDoc['name'] ?? '';
            fullCapacityController.text = userDoc['vehicleCapacity'] ?? '';
            vehicleNoController.text = userDoc['vehicleNo'] ?? '';
            emailController.text = userDoc['email'] ?? '';
            teleController.text = userDoc['phone'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text.trim(),
          'vehicleCapacity': fullCapacityController.text.trim(),
          'vehicleNo': vehicleNoController.text.trim(),
          'phone': teleController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!')),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("EV Owner Profile",
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField(nameController, "EV Owner Name"),
            const SizedBox(height: 15),

            _buildTextField(fullCapacityController, "Full Capacity"),
            const SizedBox(height: 15),

            _buildTextField(vehicleNoController, "Vehicle Number"),
            const SizedBox(height: 15),

            _buildTextField(emailController, "Email", fontSize: 14),
            const SizedBox(height: 15),

            _buildTextField(teleController, "Phone Number"),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {double fontSize = 16}) {
    return TextField(
      controller: controller,
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
      style: TextStyle(fontSize: fontSize),
    );
  }
}