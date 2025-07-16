import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2g_app/src/features/authentication/controllers/signup/ev_signup_controller.dart';
import '../../../core/screens/Dashboard/dashboard.dart';

class EvOwnerSignup extends StatelessWidget {
  EvOwnerSignup({super.key});

  final controller = Get.put(EvSignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text('Electric Vehicle Owner Sign Up', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Enter your Details Below',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            buildTextField(controller.vehicleNo, 'Vehicle Number'),
            buildTextField(controller.name, 'Full Name'),
            buildTextField(controller.tele, 'Phone Number'),
            buildTextField(controller.fullCapacity, 'Full Capacity Of The Vehicle (kWh)',
                keyboardType: TextInputType.number),
            buildTextField(controller.walletAddress, 'MetaMask Wallet Address'),
            buildTextField(controller.email, 'Email'),
            buildTextField(controller.password, 'Password', obscure: true),
            buildTextField(controller.rePassword, 'Re-Enter Password', obscure: true),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                // ✅ Validation
                if (controller.password.text.isEmpty ||
                    controller.rePassword.text.isEmpty ||
                    controller.password.text != controller.rePassword.text) {
                  showPopupDialog(context, 'Password mismatch or empty!', 'Error');
                  return;
                }

                if (controller.vehicleNo.text.isEmpty ||
                    controller.name.text.isEmpty ||
                    controller.tele.text.isEmpty ||
                    controller.fullCapacity.text.isEmpty ||
                    controller.walletAddress.text.isEmpty ||
                    controller.email.text.isEmpty) {
                  showPopupDialog(context, 'All fields are required.', 'Error');
                  return;
                }

                if (!isValidEthereumAddress(controller.walletAddress.text.trim())) {
                  showPopupDialog(context, 'Invalid Ethereum address.', 'Error');
                  return;
                }

                // ✅ Firebase registration
                final error = await controller.registerUser(
                  controller.email.text.trim(),
                  controller.password.text.trim(),
                );

                if (error == null) {
                  // ✅ Blockchain registration
                  final chainError = await controller.registerEVOwnerOnBlockchain();
                  if (chainError == null) {
                    await showPopupDialog(context, 'Registration Successful!', 'Success');
                    Get.offAll(() => const evDash());
                  } else {
                    showPopupDialog(context, 'Blockchain Error: $chainError', 'Error');
                  }
                } else {
                  showPopupDialog(context, 'Firebase Error: $error', 'Error');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text('NEXT', style: TextStyle(color: Colors.white, fontSize: 20)),
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

  Widget buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
          ),
          keyboardType: keyboardType,
          obscureText: obscure,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> showPopupDialog(BuildContext context, String message, String title) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        );
      },
    );
  }

  bool isValidEthereumAddress(String address) {
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(address);
  }
}