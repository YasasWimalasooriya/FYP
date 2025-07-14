import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Profile/profile.dart';

class MonitorResponses extends StatefulWidget {
  const MonitorResponses({super.key});

  @override
  State<MonitorResponses> createState() => _MonitorResponsesState();
}

class _MonitorResponsesState extends State<MonitorResponses> {
  double totalDischargeableEnergy = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalDischargeableEnergy();
  }

  Future<String> getEvOwnerName(String? userId) async {
    if (userId == null) return 'Unknown EV Owner';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();
      return userData?['name'] ?? userData?['email'] ?? 'Unknown EV Owner';
    } catch (_) {
      return 'Unknown EV Owner';
    }
  }

  Future<void> calculateTotalDischargeableEnergy() async {
    final snapshot = await FirebaseFirestore.instance.collection('discharged_requests').get();
    double total = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      try {
        double discharged = (data['energyDischarged'] ?? 0.0).toDouble();
        total += discharged;
      } catch (_) {
        continue;
      }
    }

    setState(() {
      totalDischargeableEnergy = double.parse(total.toStringAsFixed(2));
    });
  }

  Future<void> deleteAllResponses() async {
    final batch = FirebaseFirestore.instance.batch();
    final collection = await FirebaseFirestore.instance.collection('discharged_requests').get();

    for (var doc in collection.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    setState(() {
      totalDischargeableEnergy = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All responses cleared.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Monitor Responses", style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green[800],
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total Reported Dischargeable Energy: $totalDischargeableEnergy kWh',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discharged_requests')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No responses yet."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final energy = (data['energyDischarged'] ?? 0.0) as num;
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final userId = data['userId'];

                    if (userId == null || userId is! String) {
                      return _buildCard("Unknown EV Owner", energy.toDouble(), timestamp);
                    }

                    return FutureBuilder<String>(
                      future: getEvOwnerName(userId),
                      builder: (context, ownerSnapshot) {
                        final ownerName = ownerSnapshot.data ?? 'EV Owner';
                        return _buildCard(ownerName, energy.toDouble(), timestamp);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content: const Text("Are you sure you want to clear all responses? This action cannot be undone."),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      TextButton(
                        child: const Text("Clear All", style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await deleteAllResponses();
                }
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                "Clear All Responses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String owner, double energy, DateTime time) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: Colors.green[900],
      child: ListTile(
        title: Text('Willing to Discharge: $energy kWh', style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${time.toLocal()}', style: const TextStyle(color: Colors.white)),
            Text('Owner: $owner', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}