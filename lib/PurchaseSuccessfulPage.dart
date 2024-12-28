import 'package:flutter/material.dart';
import 'package:mobile_app_final/homepage.dart';

class PurchaseSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        title: Text(
          'Purchase Successful',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfff0f4f7),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Color(0xff39c4c9),
            ),
            SizedBox(height: 16),
            Text(
              'Your purchase was successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff39c4c9),
              ),
            ),
            SizedBox(height: 10),
            // Add the thank you message below
            Text(
              'Thank you for choosing Curasync Pharmacy!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700], // Adjust the color as you like
              ),
            ),
            SizedBox(height: 32), // Add some space
            ElevatedButton(
              onPressed: () {
                // Go to home page or any other page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => homePage()),
                );
              },
              child: Text(
                'Back to Home',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
