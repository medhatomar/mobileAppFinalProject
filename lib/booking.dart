// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final double rating;
  final String fees;
  final String waiting;
  final String location;

  const Booking({
    Key? key,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.rating,
    required this.fees,
    required this.waiting,
    required this.location,
  }) : super(key: key);

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<String> bookedSlots = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (_selectedDate != null) {
      _fetchBookedSlots();
    }
  }

  Future<void> _fetchBookedSlots() async {
    if (_selectedDate == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final snapshot = await _firestore
        .collection('Bookings')
        .where('doctorName', isEqualTo: widget.doctorName)
        .where('date', isEqualTo: formattedDate)
        .get();

    if (mounted) {
      setState(() {
        bookedSlots =
            snapshot.docs.map((doc) => doc['timeSlot'] as String).toList();
      });
    }
  }

  Future<void> _cancelBooking() async {
    if (_selectedDate == null || _selectedSlot == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final snapshot = await _firestore
        .collection('Bookings')
        .where('doctorName', isEqualTo: widget.doctorName)
        .where('date', isEqualTo: formattedDate)
        .where('timeSlot', isEqualTo: _selectedSlot)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;

      // Delete the appointment from Firestore
      await _firestore.collection('Bookings').doc(docId).delete();

      // Remove from the local state (AppointmentModel)
      final model = Provider.of<AppointmentModel>(context, listen: false);

      // Find and remove the canceled appointment from the model's list
      final canceledAppointmentIndex = model.appointments.indexWhere(
        (appointment) =>
            appointment['doctorName'] == widget.doctorName &&
            appointment['date'] == formattedDate &&
            appointment['timeSlot'] == _selectedSlot,
      );

      if (canceledAppointmentIndex != -1) {
        model.removeAppointment(canceledAppointmentIndex);
      }

      setState(() {
        bookedSlots.remove(_selectedSlot!);
        _selectedSlot = null;
      });
    }
  }

  Future<void> _bookSlot(String timeSlot) async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      // Check if the slot is already booked
      final snapshot = await _firestore
          .collection('Bookings')
          .where('doctorName', isEqualTo: widget.doctorName)
          .where('date', isEqualTo: formattedDate)
          .where('timeSlot', isEqualTo: timeSlot)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This slot is already booked.')),
        );
        return;
      }

      // Add the appointment to Firestore
      final newAppointment = {
        'doctorName': widget.doctorName,
        'specialty': widget.specialty,
        'date': formattedDate,
        'timeSlot': timeSlot,
        'location': widget.location,
        'fees': widget.fees,
      };

      final model = Provider.of<AppointmentModel>(context, listen: false);
      await model.addAppointment(newAppointment);

      setState(() {
        _selectedSlot = timeSlot;
        bookedSlots.add(timeSlot);
        _isLoading = false;
      });

      _showConfirmationDialog(formattedDate, timeSlot);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _showConfirmationDialog(String formattedDate, String timeSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Color(0xff39c4c9),
              size: 60,
            ),
            SizedBox(height: 10),
            Text(
              'Booking Confirmed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, 'Doctor', widget.doctorName),
                  _buildInfoRow(
                      Icons.medical_services, 'Specialty', widget.specialty),
                  _buildInfoRow(
                      Icons.access_time, 'Waiting Time', widget.waiting),
                  _buildInfoRow(Icons.calendar_today, 'Date & Time',
                      '$formattedDate, $timeSlot'),
                  _buildInfoRow(Icons.location_on, 'Location', widget.location),
                  _buildInfoRow(Icons.attach_money, 'Fees', widget.fees),
                ],
              ),
            ),
            Divider(),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Color(0xff39c4c9)),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Activity()),
            ),
            child: Center(
              child: Text(
                'OK',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 8), // Add spacing between buttons
          // Cancel Button
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.red),
            ),
            onPressed: () async {
              await _cancelBooking(); // Call cancel booking function
              Navigator.of(context).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking has been canceled.')),
              );
            },
            child: Center(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xff39c4c9), size: 20),
          SizedBox(width: 10),
          Text('$label: $value', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDate != null) {
      _fetchBookedSlots();
    }
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: AssetImage('assets/images/CuraSyncLogo.png'),
              width: 200,
              height: 200,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home Button
            ElevatedButton(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: Color(0xff39c4c9),
                    size: 24,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Color(0xff39c4c9),
                      fontSize: 12.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            // Activity Button with Notification Badge
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
                        color: Color(0xffa9a9a9),
                        size: 24,
                      ),
                      Text(
                        'My Activity',
                        style: TextStyle(
                          color: Color(0xffa9a9a9),
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
            // Profile Button
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    color: Color(0xffa9a9a9),
                    Icons.person,
                    size: 24,
                  ),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Color(0xffa9a9a9),
                      fontSize: 12.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Doctor Information Card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(widget.doctorImage),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff39c4c9),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                if (index < widget.rating.floor()) {
                                  return Icon(Icons.star,
                                      color: Colors.yellow[700], size: 20);
                                } else if (index == widget.rating.floor() &&
                                    widget.rating % 1 != 0) {
                                  return Icon(Icons.star_half,
                                      color: Colors.yellow[700], size: 20);
                                } else {
                                  return Icon(Icons.star_border,
                                      color: Colors.grey, size: 20);
                                }
                              }),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.specialty,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Available Slots Card
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Color(0xff39c4c9),
                              size:
                                  25, // You can adjust the size of the icon as needed
                            ),
                            Text(
                              "Fees: ${widget.fees}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                            color: const Color.fromARGB(161, 208, 204, 204)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Color(0xff39c4c9), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "${widget.location}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(
                            color: const Color.fromARGB(161, 208, 204, 204)),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Color(0xff39c4c9), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Waiting time: ${widget.waiting}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Divider(
                            color: const Color.fromARGB(161, 208, 204, 204)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Choose your appointment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff39c4c9),
                          ),
                        ),
                        SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xff39c4c9)),
                          ),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 30)),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Color(0xff39c4c9),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xff39c4c9),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            style: TextStyle(color: Color(0xff39c4c9)),
                            _selectedDate == null
                                ? "Choose Date"
                                : "Selected: ${DateFormat('yMMMd').format(_selectedDate!)}",
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          SizedBox(height: 16),
                          Text(
                            "Available Slots",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff39c4c9),
                            ),
                          ),
                          SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildSlotButton("9:00 AM"),
                              _buildSlotButton("10:00 AM"),
                              _buildSlotButton("11:00 AM"),
                              _buildSlotButton("1:00 PM"),
                              _buildSlotButton("3:00 PM"),
                              _buildSlotButton("4:00 PM"),
                            ],
                          ),
                          if (_selectedSlot != null) //
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff39c4c9),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          if (_selectedDate != null &&
                                              _selectedSlot != null) {
                                            _bookSlot(_selectedSlot!);
                                          }
                                        },
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors.white), // Loading spinner
                                        )
                                      : Text(
                                          'Confirm Booking',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ],
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

  Widget _buildSlotSelectionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select a Date",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff39c4c9),
                ),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _selectedSlot = null;
                      bookedSlots.clear();
                    });

                    await _fetchBookedSlots();
                  }
                },
                child: Text(
                  _selectedDate == null
                      ? "Choose Date"
                      : "Selected: ${DateFormat('yMMMd').format(_selectedDate!)}",
                  style: TextStyle(color: Color(0xff39c4c9)),
                ),
              ),
              if (_selectedDate != null) ...[
                SizedBox(height: 16),
                Text(
                  "Available Slots",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff39c4c9),
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSlotButton("9:00 AM"),
                    _buildSlotButton("10:00 AM"),
                    _buildSlotButton("11:00 AM"),
                    _buildSlotButton("1:00 PM"),
                    _buildSlotButton("3:00 PM"),
                    _buildSlotButton("4:00 PM"),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotButton(String time) {
    bool isBooked = bookedSlots.contains(time); // Check if the slot is booked
    return OutlinedButton(
      onPressed: isBooked
          ? null // Disable button if the slot is already booked
          : () {
              setState(() {
                _selectedSlot = time; // Set the selected slot
              });
            },
      style: OutlinedButton.styleFrom(
        backgroundColor: isBooked
            ? Colors.grey[300] // Greyed-out background for booked slots
            : (_selectedSlot == time ? Color(0xff39c4c9) : Colors.white),
        side: BorderSide(color: isBooked ? Colors.grey : Color(0xff39c4c9)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 14,
          color: isBooked
              ? Colors.grey // Grey text for booked slots
              : (_selectedSlot == time ? Colors.white : Color(0xff39c4c9)),
          fontWeight: isBooked ? FontWeight.normal : FontWeight.bold,
          decoration: isBooked
              ? TextDecoration.lineThrough // Strike-through for booked slots
              : TextDecoration.none,
        ),
      ),
    );
  }
}
