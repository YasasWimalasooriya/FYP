import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EvSignupController extends GetxController {
  // Form controllers
  final vehicleNo = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final tele = TextEditingController();
  final fullCapacity = TextEditingController();
  final walletAddress = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();

  Future<String?> registerUser(String email, String password) async {
    try {
      // Step 1: Register with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'vehicleNo': vehicleNo.text.trim(),
        'name': name.text.trim(),
        'email': email.trim(),
        'phone': tele.text.trim(),
        'vehicleCapacity': fullCapacity.text.trim(),
        'walletAddress': walletAddress.text.trim(), // Store MetaMask address
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'ev_owner',
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}