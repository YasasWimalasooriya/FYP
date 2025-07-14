import 'package:flutter/material.dart';

class NotificationLogs extends StatelessWidget {
  const NotificationLogs({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy logs
    final logs = [
      {"message": "Request for 3kWh sent", "timestamp": "2025-04-04 14:22"},
      {"message": "EV Owner 1 accepted", "timestamp": "2025-04-04 14:23"},
      {"message": "EV Owner 2 declined", "timestamp": "2025-04-04 14:24"},
    ];

    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Notification Logs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            title: Text(log["message"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log["timestamp"]!),
            leading: const Icon(Icons.notifications, color: Colors.green),
          );
        },
      ),
    );
  }
}
