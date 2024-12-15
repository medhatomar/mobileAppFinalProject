// ignore_for_file: unused_import, prefer_const_constructors, duplicate_ignore
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, duplicate_import

import 'package:flutter/material.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'procedures.dart';

class Surgical extends StatefulWidget {
  const Surgical({super.key});

  @override
  State<StatefulWidget> createState() => _SurgicalState();
}

Widget _buildStep(int number, String title, String subtitle) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff39c4c9),
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Texts (title and subtitle)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SurgicalState extends State<Surgical> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xff39c4c9),
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services',
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(
          children: [
            Row(children: [
              SizedBox(
                height: 25,
                width: 25,
              ),
              Text("How it works",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            Center(
              child: Container(
                height: 350,
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 3,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(1, 'Choose your area',
                        'You can select the nearset branch to you'),
                    const SizedBox(height: 16),
                    _buildStep(2, 'Add your surgical operation',
                        'Many operations for multiple specialties'),
                    const SizedBox(height: 16),
                    _buildStep(3, 'Select Branch',
                        'Compare availability,prices,location & working hours'),
                    const SizedBox(height: 16),
                    _buildStep(4, 'Read service preparations',
                        'Follow the instructions before your visit'),
                    const SizedBox(height: 15),
                    _buildStep(
                        5, 'Select data', 'Schadule your visit to the branch'),
                  ],
                ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => homePage()),
                  );
                },
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
