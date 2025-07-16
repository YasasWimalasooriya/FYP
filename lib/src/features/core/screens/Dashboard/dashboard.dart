import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../map/charging_stations.dart';
import '../Exchange/exchange_rate.dart';
import '../profile/profile.dart';
import '../Notifications/notifications.dart';

class evDash extends StatefulWidget {
  const evDash({super.key});

  @override
  State<evDash> createState() => _evDashState();
}

class _evDashState extends State<evDash> {
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

  Future<void> _launchMetaMask() async {
    final Uri url = Uri.parse('https://metamask.io');
    if (await canLaunchUrl(url)) {
      final bool launched =
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open MetaMask website')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MetaMask URL is not valid')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text(
          "Dashboard",
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
              value: false, // Replace with actual toggle logic if needed
              onChanged: (bool value) {
                // TODO: Implement theme toggle if required
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/image4.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),

                _dashboardButton(
                  context,
                  icon: Icons.notifications,
                  text: "Notifications",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Notifications()),
                  ),
                ),
                const SizedBox(height: 20),

                _dashboardButton(
                  context,
                  icon: Icons.ev_station,
                  text: "Charging Stations",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChargingStations()),
                  ),
                ),
                const SizedBox(height: 20),

                _dashboardButton(
                  context,
                  icon: Icons.currency_exchange,
                  text: "Exchange Rates",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExchangeRate()),
                  ),
                ),
                const SizedBox(height: 20),

                _dashboardButton(
                  context,
                  icon: Icons.account_balance_wallet,
                  text: "Wallet",
                  onTap: _launchMetaMask,
                ),
                const SizedBox(height: 20),

                _dashboardButton(
                  context,
                  icon: Icons.bolt,
                  text: "Charge Vehicle",
                  onTap: () {
                    Navigator.pushNamed(context, '/chargeVehicle');
                  },
                ),
              ],
            ),
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
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}