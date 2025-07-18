import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../services/blockchain_service.dart';

class EvSignupController extends GetxController {
  final vehicleNo = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final tele = TextEditingController();
  final fullCapacity = TextEditingController();
  final walletAddress = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "vehicleNo": vehicleNo.text.trim(),
        "name": name.text.trim(),
        "email": email.trim(),
        "phone": tele.text.trim(),
        "vehicleCapacity": fullCapacity.text.trim(),
        "walletAddress": walletAddress.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
        "role": "ev_owner",
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> registerEVOwnerOnBlockchain() async {
    try {
      final blockchain = BlockchainService();
      await blockchain.init();

      final BigInt maxCapacity = BigInt.parse(fullCapacity.text.trim());
      final BigInt minBattery = maxCapacity ~/ BigInt.from(5); // 20% safety buffer

      return await blockchain.registerEVOwner(
        walletAddress: walletAddress.text.trim(),
        maxDischargeCapacity: maxCapacity,
        minBatteryLevel: minBattery,
      );
    } catch (e) {
      return e.toString();
    }
  }
}