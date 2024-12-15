import 'package:flutter/material.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:mobile_app_final/myquestions.dart';

class MedicalQuestionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: Text(
          'My Questions',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Message icon
            Icon(
              Icons.message,
              size: 80,
              color: Color(0xff39c4c9), // Customize the color of the icon
            ),
            SizedBox(height: 20),
            // Text below the icon
            Text(
              'Have a medical question? Ask a doctor for free',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            // Ask Now button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyQuestions()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff39c4c9), // Button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                'Ask Now',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensures the column is as small as possible
                  children: [
                    Icon(
                      Icons.home_outlined,
                      color: Color(0xff39c4c9),
                      size: 24, // You can adjust the size of the icon as needed
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Color(0xff39c4c9),
                        fontSize: 12.5,
                        height: 1.0, // Reduces line height for tighter spacing
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                overlayColor: Colors.transparent,
              ),
              onPressed: () {},
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensures the column is as small as possible
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xffa9a9a9),
                    size: 24, // You can adjust the size of the icon as needed
                  ),
                  Text(
                    'My Activity',
                    style: TextStyle(
                      color: Color(0xffa9a9a9),
                      fontSize: 12.5,
                      height: 1.0, // Reduces line height for tighter spacing
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                overlayColor: Colors.transparent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Myprofile()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensures the column is as small as possible
                children: [
                  Icon(
                    color: Color(0xffa9a9a9),
                    Icons.person,
                    size: 24, // You can adjust the size of the icon as needed
                  ),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Color(0xffa9a9a9),
                      fontSize: 12.5,
                      height: 1.0, // Reduces line height for tighter spacing
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MedicalQuestionPage(),
  ));
}
