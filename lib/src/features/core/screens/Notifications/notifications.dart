import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Accept_Page/discharge_confirmation.dart';
import '../profile/profile.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final Map<String, bool> respondedStatus = {};

  void respondToNotification(String docId, double energy, bool accepted) {
    setState(() {
      respondedStatus[docId] = true;
    });

    if (accepted) {
      double batteryLevel = 40.0; // kWh
      double destinationDistance = 10.0; // km
      double vehicleEfficiency = 5.0; // km per kWh

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DischargeConfirmation(
            energyAmount: energy,
            docId: docId,
            batteryLevel: batteryLevel,
            destinationDistance: destinationDistance,
            vehicleEfficiency: vehicleEfficiency,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You declined the request.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('for', isEqualTo: 'ev_owners')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String id = doc.id;
              final String message = data['message'] ?? '';
              final double energy = (data['energy'] as num?)?.toDouble() ?? 0.0;
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final String timeString =
              DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate());

              final bool responded = respondedStatus[id] ?? false;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: Colors.green[900],
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: $timeString',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Requested Energy: $energy kWh',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      if (!responded)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => respondToNotification(id, energy, true),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text("Accept"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => respondToNotification(id, energy, false),
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text("Decline", style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      else
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Response Recorded',
                            style: TextStyle(color: Colors.green[200]),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}