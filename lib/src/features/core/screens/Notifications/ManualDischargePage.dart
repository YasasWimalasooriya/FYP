import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualDischargePage extends StatefulWidget {
  final String docId;
  final double defaultEnergy;

  const ManualDischargePage({
    super.key,
    required this.docId,
    required this.defaultEnergy,
  });

  @override
  State<ManualDischargePage> createState() => _ManualDischargePageState();
}

class _ManualDischargePageState extends State<ManualDischargePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.defaultEnergy.toStringAsFixed(2);
  }

  Future<void> submitDischarge() async {
    final energy = double.tryParse(_controller.text.trim());
    if (energy == null || energy <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid energy amount."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('notifications').doc(widget.docId).update({
        'manualDischarge': energy,
        'status': 'ManuallyDischarged',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Energy discharged successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
        title: const Text("Manual Discharge", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.flash_on, size: 80, color: Colors.yellow),
            const SizedBox(height: 16),
            const Text(
              "Enter energy to discharge to the grid:",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Energy (kWh)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
              onPressed: submitDischarge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}