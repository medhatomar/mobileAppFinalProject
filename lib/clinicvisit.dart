import 'package:flutter/material.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/doctorprofile.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'doctorprofile.dart';
import 'package:provider/provider.dart'; // Import the provider package

class clinicvisit extends StatefulWidget {
  final List<String> selectedCities;
  const clinicvisit({Key? key, required this.selectedCities}) : super(key: key);

  @override
  State<clinicvisit> createState() => _clinicvisitState();
}

class _clinicvisitState extends State<clinicvisit> {
  final List<String> specialties = [
    "Cardiology",
    "Dermatology",
    "Neurology",
    "Pediatrics",
    "Orthopedics",
    "Dentistry",
    "Psychiatry",
    "Gynaecology and Infertility",
    "Ear, Nose and Throat",
    "Internal Medicine",
  ];

  final List<String> otherSpecialties = [
    "Allergy",
    "Andrology",
    "Audiology",
    "Thoracic",
    "Chest and Respiratory",
    "Diabetes",
    "Radiology",
    "Nutrition",
    "General Surgery",
    "Plastic Surgery",
    "Spinal Surgery",
  ];
  final List<String> otherImages = [
    'assets/images/allergy.png', //allergy
    'assets/images/male-gender.png', //andrology
    'assets/images/ear.png', //ears
    'assets/images/organs.png', //thoracic
    'assets/images/chest-pain.png', //chest
    'assets/images/diabetes.png', //diabetes
    'assets/images/radiology.png', //radiology
    'assets/images/plan.png', //nutrition
    'assets/images/doctor.png', //general
    'assets/images/cosmetic-surgery.png', //plastic
    'assets/images/spine.png', //spinal
  ];

  final List<String> specialtyImages = [
    'assets/images/cardio.png',
    'assets/images/derma.png',
    'assets/images/brain.png',
    'assets/images/newborn.png',
    'assets/images/broken.png',
    'assets/images/tooth.png',
    'assets/images/mindset.png',
    'assets/images/embryo.png',
    'assets/images/healthcare.png',
    'assets/images/internal.png',
  ];

  final Map<String, List<String>> keywordMappings = {
    "heart": ["Cardiology"],
    "hea": ["Cardiology"],
    "hear": ["Cardiology"],
    "h": ["Cardiology"],
    "skin": ["Dermatology"],
    "brain": ["Neurology"],
    "children": ["Pediatrics"],
    "bones": ["Orthopedics"],
    "teeth": ["Dentistry"],
    "mind": ["Psychiatry"],
    "women": ["Gynaecology and Infertility"],
    "ears": ["Ear, Nose and Throat"],
    "nose": ["Ear, Nose and Throat"],
    "throat": ["Ear, Nose and Throat"],
    "internal": ["Internal Medicine"],
  };

  List<String> allItems = [];
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    allItems = [...specialties, ...otherSpecialties];
    filteredItems = allItems;
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        final lowerQuery = query.toLowerCase();
        final keywordResults = keywordMappings.entries
            .where((entry) => lowerQuery.contains(entry.key))
            .expand((entry) => entry.value)
            .toList();

        filteredItems = allItems
            .where((item) =>
                item.toLowerCase().contains(lowerQuery) ||
                keywordResults.contains(item))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: TextField(
                  onChanged: _searchItems,
                  decoration: InputDecoration(
                    hintText: 'Search for specialty, doctor or hospital',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
              child: Text(
                'Most Popular Specialties',
                style: TextStyle(
                  color: Color(0xff39c4c9),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return filteredItems.contains(specialties[index])
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 3),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: Image(
                              image: AssetImage(specialtyImages[index]),
                              width: 40,
                              height: 40,
                              color: Color(0xff39c4c9),
                            ),
                            title: Text(
                              specialties[index],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Doctorprofile(
                                          specialtyName: specialties[index],
                                          cities: widget.selectedCities,
                                        )),
                              );
                            },
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              },
              childCount: specialties.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 0, 10),
              child: Text(
                'Other Specialties',
                style: TextStyle(
                  color: Color(0xff39c4c9),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return filteredItems.contains(otherSpecialties[index])
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 3),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Image(
                              image: AssetImage(otherImages[index]),
                              width: 40,
                              height: 40,
                              color: Color(0xff39c4c9),
                            ),
                            title: Text(
                              otherSpecialties[index],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Doctorprofile(
                                          specialtyName:
                                              otherSpecialties[index],
                                          cities: widget.selectedCities,
                                        )),
                              );
                            },
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              },
              childCount: otherSpecialties.length,
            ),
          ),
        ],
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
