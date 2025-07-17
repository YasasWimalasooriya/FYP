import 'package:flutter/material.dart';

import 'ev_owner_login.dart';
import 'sys_operator_login.dart';

class login_selection extends StatelessWidget {
  const login_selection({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add image2 at the top of the page
            Container(
              width: width,
              height: height*0.2,
              decoration: BoxDecoration(
                image: DecorationImage( image: AssetImage("assets/images/loginCover.png"),fit: BoxFit.cover,),)
              ),

             SizedBox(height:height*0.1),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => evOwnerLogin(),
                ),
              ),
              child: Container(
                width: width*0.7,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
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

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("or"),
              ],
            ),// Space between the two boxes
            const SizedBox(height: 10),

            // Space between image3 and the next button

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => sysOpLogin(),
                ),
              ),
              child: Container(
                width: width*0.7,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
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


