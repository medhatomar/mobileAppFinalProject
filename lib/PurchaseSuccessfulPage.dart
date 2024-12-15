import 'package:flutter/material.dart';
import 'package:mobile_app_final/homepage.dart';

class PurchaseSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        title: Text('Purchase Successful'),
        backgroundColor: Color(0xfff0f4f7),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Your purchase was successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Go to home page or any other page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => homePage()),
                );
              },
              child: Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff39c4c9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
