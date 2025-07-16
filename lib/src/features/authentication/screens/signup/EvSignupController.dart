import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../services/blockchain_service.dart';

class EvSignupController extends GetxController {
  final vehicleNo = TextEditingController();
  final name = TextEditingController();
  final tele = TextEditingController();
  final fullCapacity = TextEditingController();
  final minBattery = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Register user in Firebase
  Future<String?> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save to Firestore
      await _firestore.collection("ev_owners").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "vehicleNo": vehicleNo.text.trim(),
        "name": name.text.trim(),
        "telephone": tele.text.trim(),
        "fullCapacity": fullCapacity.text.trim(),
        "minBatteryLevel": minBattery.text.trim(),
        "walletAddress": "", // to be filled after blockchain registration
        "email": email.trim(),
        "role": "ev_owner",
        "timestamp": FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Register EV owner on blockchain
  Future<String?> registerEVOwnerOnBlockchain({
    required String walletAddress,
  }) async {
    try {
      final blockchain = BlockchainService();
      await blockchain.init();

      final BigInt maxDischarge = BigInt.parse(fullCapacity.text.trim());
      final BigInt minBatteryLevel = BigInt.parse(minBattery.text.trim());

      await blockchain.registerEVOwner(
        walletAddress: walletAddress,
        maxDischargeCapacity: maxDischarge,
        minBatteryLevel: minBatteryLevel,
      );

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }
}