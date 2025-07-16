import 'package:flutter/material.dart';
import '../../../../../services/blockchain_service.dart';

class PurchaseEnergyTokensPage extends StatefulWidget {
  const PurchaseEnergyTokensPage({Key? key}) : super(key: key);

  @override
  State<PurchaseEnergyTokensPage> createState() => _PurchaseEnergyTokensPageState();
}

class _PurchaseEnergyTokensPageState extends State<PurchaseEnergyTokensPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _energyAmountController = TextEditingController();
  bool _isPeak = false;
  bool _isLoading = false;

  final BlockchainService _blockchainService = BlockchainService();

  @override
  void initState() {
    super.initState();
    _blockchainService.init(); // Ensure blockchain is initialized
  }

  Future<void> _purchaseEnergyTokens() async {
    if (!_formKey.currentState!.validate()) return;

    final energyKWh = BigInt.from(int.parse(_energyAmountController.text));
    setState(() => _isLoading = true);

    try {
      final txHash = await _blockchainService.purchaseEnergyTokens(
        energyAmountKWh: energyKWh,
        isPeakHours: _isPeak,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[700],
          content: Text('✅ Purchase Successful\nTx: $txHash'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('❌ Error: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _energyAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Charge Vehicle',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Enter Energy Amount (kWh)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _energyAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Energy (kWh)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter energy amount';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Is Peak Hours?"),
                  activeColor: Colors.green[900],
                  value: _isPeak,
                  onChanged: (val) => setState(() => _isPeak = val),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _purchaseEnergyTokens,
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  label: const Text(
                    "Purchase Tokens",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
