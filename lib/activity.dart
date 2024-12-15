import 'package:flutter/material.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the AppointmentModel for managing state
class AppointmentModel extends ChangeNotifier {
  List<Map<String, String>> _appointments = [];
  String? selectedDoctorName;
  String? selectedSpecialty;
  String? selectedDate;
  String? selectedTimeSlot;
  int get notificationCount => _appointments.length;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, String>> get appointments => _appointments;

  Future<void> fetchAppointments() async {
    try {
      // Clear the list before fetching new data
      _appointments.clear();

      final snapshot = await firestore.collection('Bookings').get();
      final List<Map<String, String>> fetchedAppointments =
          snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'doctorName': data['doctorName']?.toString() ?? '',
          'specialty': data['specialty']?.toString() ?? '',
          'date': data['date']?.toString() ?? '',
          'timeSlot': data['timeSlot']?.toString() ?? '',
          'fees': data['fees']?.toString() ?? '',
        };
      }).toList();

      _appointments = fetchedAppointments;
      notifyListeners();
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  Future<void> addAppointment(Map<String, String> appointment) async {
    try {
      final docRef = await firestore.collection('Bookings').add({
        'doctorName': appointment['doctorName'],
        'specialty': appointment['specialty'],
        'date': appointment['date'],
        'timeSlot': appointment['timeSlot'],
        'fees': appointment['fees'],
      });

      appointment['id'] = docRef.id;
      _appointments.add(appointment);
      notifyListeners();
    } catch (e) {
      print('Error adding appointment: $e');
    }
  }

  void removeAppointment(int index) {
    _appointments.removeAt(index);
    notifyListeners();
  }

  void setSelectedAppointment(
      String doctorName, String specialty, String date, String timeSlot) {
    selectedDoctorName = doctorName;
    selectedSpecialty = specialty;
    selectedDate = date;
    selectedTimeSlot = timeSlot;
    notifyListeners();
  }
}

// Define the Activity class
class Activity extends StatefulWidget {
  @override
  ActivityState createState() => ActivityState();
}

class ActivityState extends State<Activity> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _cancelAppointment(String appointmentId, int index) async {
    try {
      final model = Provider.of<AppointmentModel>(context, listen: false);

      final snapshot = await _firestore
          .collection('Bookings')
          .where('doctorName', isEqualTo: model.selectedDoctorName)
          .where('date', isEqualTo: model.selectedDate)
          .where('timeSlot', isEqualTo: model.selectedTimeSlot)
          .where('specialty', isEqualTo: model.selectedSpecialty)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestore.collection('Bookings').doc(docId).delete();
      }

      // Remove the appointment from the local list
      model.removeAppointment(index); // This should notify listeners
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment cancelled successfully')),
      );
    } catch (e) {
      print('Error canceling appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final model = Provider.of<AppointmentModel>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    model.fetchAppointments();
  }

  @override
  void dispose() {
    // Unregister the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the app is resumed (foreground), refresh the appointments and notification count
    if (state == AppLifecycleState.resumed) {
      final model = Provider.of<AppointmentModel>(context, listen: false);
      model.fetchAppointments(); // Refresh the appointments
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: Text(
          'Activity',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppointmentModel>(
        builder: (context, model, child) {
          final appointments = model.appointments;
          return appointments.isEmpty
              ? Center(child: Text('No appointments yet'))
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final appointmentId = appointment['id'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(appointment['doctorName']!),
                          subtitle: Text(
                              '${appointment['specialty']} • ${appointment['date']} at ${appointment['timeSlot']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${appointment['fees']}',
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () =>
                                    _cancelAppointment(appointmentId, index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
                    color: Color(0xffa9a9a9),
                    size: 24,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Color(0xffa9a9a9),
                      fontSize: 12.5,
                      height: 1.0,
                    ),
                  ),
                ],
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
                        color: Color(0xff39c4c9),
                        size: 24,
                      ),
                      Text(
                        'My Activity',
                        style: TextStyle(
                          color: Color(0xff39c4c9),
                          fontSize: 12.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<AppointmentModel>(
                  builder: (context, model, child) {
                    return Positioned(
                      right: 8,
                      top: 2,
                      child: model.notificationCount > 0
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
                          : SizedBox.shrink(),
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
    );
  }
}
