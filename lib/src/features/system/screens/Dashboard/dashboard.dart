import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile/profile.dart';
import 'discharge/request_discharge.dart';
import 'monitor/monitor_responses.dart';
import 'notifications/notification_logs.dart';
import 'google_map_screen.dart';

class SystemOperatorDashboard extends StatefulWidget {
  const SystemOperatorDashboard({super.key});

  @override
  State<SystemOperatorDashboard> createState() => _SystemOperatorDashboardState();
}

class _SystemOperatorDashboardState extends State<SystemOperatorDashboard> {
  String? email;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text(
          "System Operator Dashboard",
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
                MaterialPageRoute(builder: (context) => const SystemOperatorProfile()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.green[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[900]),
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: Icon(Icons.person, color: Colors.green[900], size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email ?? 'Loading email...',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.brightness_6),
              value: false,
              onChanged: (bool value) {
                // TODO: Add theme toggle logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("About Us"),
                    content: const Text(
                        "This app is developed in collaboration with the CEB for Vehicle-to-Grid (V2G) integration."),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help / Support'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Help & Support"),
                    content: const Text(
                        "For support, contact: support@ceb.lk or call +94 11 2345678."),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy / Terms'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Privacy Policy & Terms"),
                    content: const SingleChildScrollView(
                      child: Text(
                        "By using this application, you agree to our privacy policy and terms of service. "
                            "This includes consent for collecting anonymized energy usage data and receiving notifications.",
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/R.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              _dashboardButton(
                context,
                icon: Icons.flash_on,
                text: "Request Discharge",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestDischarge()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _dashboardButton(
                context,
                icon: Icons.monitor_heart,
                text: "Monitor Responses",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MonitorResponses()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _dashboardButton(
                context,
                icon: Icons.notifications_active,
                text: "Notification Logs",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationLogs()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _dashboardButton(
                context,
                icon: Icons.map,
                text: "Charging Stations",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoogleMapScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardButton(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.green[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}