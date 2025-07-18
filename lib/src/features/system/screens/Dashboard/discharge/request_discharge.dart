import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Profile/profile.dart';
import '../../../../../../services/blockchain_service.dart';

class RequestDischarge extends StatefulWidget {
  const RequestDischarge({super.key});

  @override
  State<RequestDischarge> createState() => _RequestDischargeState();
}

class _RequestDischargeState extends State<RequestDischarge> {
  final _formKey = GlobalKey<FormState>();
  final _energyController = TextEditingController();
  final _messageController = TextEditingController();
  final _pOffPeakController = TextEditingController();
  final _pPeakController = TextEditingController();

  String _priority = 'Medium';
  bool _isLoading = false;

  Future<void> sendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final double energy = double.parse(_energyController.text.trim());
    final double pOffPeak = double.parse(_pOffPeakController.text.trim());
    final double pPeak = double.parse(_pPeakController.text.trim());
    final String message = _messageController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Convert tokens per kWh to Wei
      final BigInt pOffPeakWei = BigInt.from(pOffPeak * 1e18);
      final BigInt pPeakWei = BigInt.from(pPeak * 1e18);
      final BigInt dischargeRateWei = BigInt.from(0.5 * 1e18); // or get from UI

      // Call blockchain functions
      final blockchain = BlockchainService();
      await blockchain.init();
      await blockchain.updatePricing(
        offPeakPrice: pOffPeakWei,
        peakPrice: pPeakWei,
        dischargeRate: dischargeRateWei,
      );
      await blockchain.mintAdditionalTokens(BigInt.from(energy));

      // Save notification in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'energy': energy,
        'message': message,
        'priority': _priority,
        'timestamp': Timestamp.now(),
        'for': 'ev_owners',
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Request sent and tokens minted'),
        backgroundColor: Colors.green,
      ));

      _energyController.clear();
      _messageController.clear();
      _pOffPeakController.clear();
      _pPeakController.clear();
      setState(() => _priority = 'Medium');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Request Discharge", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SystemOperatorProfile()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_energyController, 'Required Energy (kWh)', TextInputType.number),
                const SizedBox(height: 20),
                _buildTextField(_pOffPeakController, 'P_offPeak (tokens per kWh)', TextInputType.number),
                const SizedBox(height: 20),
                _buildTextField(_pPeakController, 'P_peak (tokens per kWh)', TextInputType.number),
                const SizedBox(height: 20),
                _buildTextField(_messageController, 'Message / Reason', TextInputType.text),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: ['High', 'Medium', 'Low']
                      .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                      .toList(),
                  onChanged: (val) => setState(() => _priority = val!),
                  decoration: const InputDecoration(
                    labelText: "Priority Level",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "⚠️ Enter token prices in tokens/kWh. (e.g. 0.001)\nConversion to Wei is automatic.",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _isLoading ? null : sendRequest,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Request", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required field';
        if (type == TextInputType.number && double.tryParse(value.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }
}