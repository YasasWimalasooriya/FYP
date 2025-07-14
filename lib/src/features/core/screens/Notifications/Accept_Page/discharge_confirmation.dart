import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DischargeConfirmation extends StatefulWidget {
  final double energyAmount; // Requested discharge from system operator
  final String docId;

  // New parameters for energy calculation
  final double batteryLevel; // B in kWh
  final double destinationDistance; // D in km
  final double vehicleEfficiency; // in km per kWh

  const DischargeConfirmation({
    super.key,
    required this.energyAmount,
    required this.docId,
    required this.batteryLevel,
    required this.destinationDistance,
    required this.vehicleEfficiency,
  });

  @override
  _DischargeConfirmationState createState() => _DischargeConfirmationState();
}

class _DischargeConfirmationState extends State<DischargeConfirmation> {
  final TextEditingController _energyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _energyController.text = widget.energyAmount.toStringAsFixed(2);
  }

  Future<void> submitDischarge() async {
    final energyDischarged = double.tryParse(_energyController.text.trim());

    if (energyDischarged == null || energyDischarged <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid energy amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Energy Check Algorithm ---
    double requiredEnergy = widget.destinationDistance / widget.vehicleEfficiency;
    requiredEnergy *= 1.10; // Add 10% buffer

    double dischargeLimit = widget.batteryLevel - requiredEnergy;

    if (dischargeLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not enough charge to reach your destination"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (energyDischarged > dischargeLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "You can only discharge up to ${dischargeLimit.toStringAsFixed(2)} kWh to ensure safe travel."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.docId)
          .update({
        'dischargedEnergy': energyDischarged,
        'status': 'Discharged',
      });

      await FirebaseFirestore.instance.collection('discharged_requests').add({
        'notificationId': widget.docId,
        'energyDischarged': energyDischarged,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discharge confirmed and sent to system operator!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit discharge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Discharge In Progress", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, size: 100, color: Colors.yellow),
              const SizedBox(height: 30),
              const Text(
                "Vehicle-to-Grid (V2G)",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              Text(
                "We need ${widget.energyAmount.toStringAsFixed(2)} kWh to the grid.",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _energyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Energy to Discharge (kWh)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : ElevatedButton(
                onPressed: submitDischarge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Submit Discharge", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}