// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, duplicate_import
import 'package:flutter/material.dart';
import 'package:mobile_app_final/CitySelection.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/clinicvisit.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'surgical.dart';

class procedures extends StatefulWidget {
  const procedures({super.key});

  @override
  State<procedures> createState() => _proceduresState();
}

Widget customElevatedButton({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Widget destination,
  Color iconColor = const Color(0xff39c4c9),
  Color buttonColor = Colors.white,
  Color textColor = Colors.black,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: textColor,
          ),
        ],
      ),
    ),
  );
}

class _proceduresState extends State<procedures> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: Text(
          'Procedures',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(children: [
          //in clinic services
          customElevatedButton(
            context: context,
            icon: Icons.local_hospital,
            title: 'In-clinic services',
            subtitle: 'Search & Book surgeries across multiple clinics',
            destination: CitySelectionScreen(),
          ),
          SizedBox(height: 10),
          // surgical operations
          customElevatedButton(
            context: context,
            icon: Icons.local_hotel_outlined,
            title: 'Surgical Operations',
            subtitle: 'Search & Book surgeries across multiple hospitals',
            destination: Surgical(),
          ),
          SizedBox(height: 10),
          // Offers
          customElevatedButton(
              context: context,
              icon: Icons.local_offer_outlined,
              title: 'Offer',
              subtitle: 'Discounts & offers on medical services',
              destination: CitySelectionScreen()),
        ]),
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
            Stack(
              alignment: Alignment.topRight,
              children: [
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
                      MaterialPageRoute(builder: (context) => Activity()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                        size: 24,
                      ),
                      Text(
                        'My Activity',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Display notification badge if there are appointments
                Consumer<AppointmentModel>(
                  builder: (context, model, child) {
                    return Positioned(
                      right: 8,
                      top: 2,
                      child: model.appointments.isNotEmpty
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${model.appointments.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : SizedBox.shrink(), // Don't show if no appointments
                    );
                  },
                ),
              ],
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
