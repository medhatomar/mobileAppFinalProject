import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/booking.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:provider/provider.dart'; // Import provider for appointments

class Doctor {
  final String name;
  final String image;
  final String location;
  final String consultationFee;
  final bool availableOnline;
  final double rating;
  final String waiting;

  Doctor({
    required this.name,
    required this.image,
    required this.location,
    required this.consultationFee,
    required this.availableOnline,
    required this.rating,
    required this.waiting,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      consultationFee: data['consultationFee'] ?? '',
      availableOnline: data['availableOnline'] ?? false,
      rating: data['rating']?.toDouble() ?? 0.0,
      waiting: data['waiting'] ?? '',
    );
  }
}

class Doctorprofile extends StatefulWidget {
  final String specialtyName;
  final List<String> cities;

  const Doctorprofile({
    Key? key,
    required this.specialtyName,
    required this.cities,
  }) : super(key: key);

  @override
  State<Doctorprofile> createState() => _DoctorprofileState();
}

class _DoctorprofileState extends State<Doctorprofile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = fetchDoctors();
  }

  Future<List<Doctor>> fetchDoctors() async {
    final snapshot = await _firestore
        .collection('Doctors')
        .where('speciality', isEqualTo: widget.specialtyName)
        .get();

    // Filter by selected cities
    final allDoctors =
        snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    final filteredDoctors = allDoctors
        .where((doctor) => widget.cities.contains(doctor.location))
        .toList();

    return filteredDoctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f4f7),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/CuraSyncLogo.png',
                width: 200, height: 200),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Doctor>>(
          future: _doctorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff39c4c9),
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      'No doctors available for this specialty in the selected cities.'));
            }

            final doctors = snapshot.data!;
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(doctor.image),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff39c4c9),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: List.generate(5, (i) {
                                      if (i < doctor.rating.floor()) {
                                        return Icon(Icons.star,
                                            color: Colors.yellow[700],
                                            size: 20);
                                      } else if (i == doctor.rating.floor() &&
                                          doctor.rating % 1 != 0) {
                                        return Icon(Icons.star_half,
                                            color: Colors.yellow[700],
                                            size: 20);
                                      } else {
                                        return const Icon(Icons.star_border,
                                            color: Colors.grey, size: 20);
                                      }
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  doctor.availableOnline
                                      ? Icons.headset_mic
                                      : Icons.phone,
                                  color: const Color(0xff39c4c9),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  doctor.availableOnline
                                      ? "Available for online consultation"
                                      : "Available for in-person consultation",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xff39c4c9), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  doctor.location,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money,
                                    color: Color(0xff39c4c9), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Fees: ${doctor.consultationFee}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Color(0xff39c4c9), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Waiting time: ${doctor.waiting}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff39c4c9),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Booking(
                                      doctorName: doctor.name,
                                      doctorImage: doctor.image,
                                      specialty: widget.specialtyName,
                                      rating: doctor.rating,
                                      fees: doctor.consultationFee,
                                      location: doctor.location,
                                      waiting: doctor.waiting,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
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
