import 'package:flutter/material.dart';

import 'ev_owner_login.dart';
import 'sys_operator_login.dart';

class login_selection extends StatelessWidget {
  const login_selection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text('Choose Your Category',
          style: TextStyle(
          color: Colors.white,
        ),
      ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add image2 at the top of the page
            Image.asset(
              'assets/images/image2.jpg',
              height: 250,
              width: 350,
            ),
            const SizedBox(height:2),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => evOwnerLogin(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      'Electric Vehicle Owner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),  // Space between the two boxes

            Image.asset(
              'assets/images/image3.jpg',
              height: 300,
              width: 250,
            ),

            const SizedBox(height: 1), // Space between image3 and the next button

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => sysOpLogin(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      'System Operator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


