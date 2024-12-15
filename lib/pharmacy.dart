import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_final/Cart.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:provider/provider.dart'; // Import the provider package

class Pharmacy extends StatefulWidget {
  final String? userId; // User identifier to manage their cart

  const Pharmacy({Key? key, this.userId}) : super(key: key);

  @override
  State<Pharmacy> createState() => _PharmacyState();
}

class _PharmacyState extends State<Pharmacy> {
  late Future<List<Medicine>> medicines;
  String? _selectedMedicineId;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _addedToCart = {}; // To track medicines added to the cart
  final Map<String, bool> _isAddingToCart =
      {}; // Track loading state per medicine
  String _searchTerm = ''; // Track the search term

  @override
  void initState() {
    super.initState();
    medicines = fetchMedicines('');
    fetchCart();
  }

  Future<List<Medicine>> fetchMedicines(String drugName) async {
    // Start with a base query that fetches all medicines
    Query query = FirebaseFirestore.instance.collection('Medicines');

    if (drugName.isNotEmpty) {
      final lowerQuery = drugName
          .toLowerCase(); // Convert to lowercase for case-insensitive comparison

      try {
        // Fetch all medicines from Firestore
        final querySnapshot = await query.get();

        // Filter the medicines based on the drugName (case-insensitive match)
        final filteredMedicines = querySnapshot.docs
            .map((doc) => Medicine.fromFirestore(doc))
            .where((medicine) {
          final lowerName = medicine.name.toLowerCase();
          // Match either by partial name or full name
          return lowerName.contains(lowerQuery);
        }).toList();

        return filteredMedicines;
      } catch (e) {
        print('Error fetching medicines: $e');
        throw Exception('Failed to load medicines');
      }
    } else {
      // If no search term is provided, return all medicines
      try {
        final querySnapshot = await query.get();
        return querySnapshot.docs
            .map((doc) => Medicine.fromFirestore(doc))
            .toList();
      } catch (e) {
        print('Error fetching medicines: $e');
        throw Exception('Failed to load medicines');
      }
    }
  }

  Future<void> fetchCart() async {
    if (widget.userId == null) return;

    final cartDoc =
        FirebaseFirestore.instance.collection('Carts').doc(widget.userId);
    final cartSnapshot = await cartDoc.get();

    if (cartSnapshot.exists) {
      final cartData = cartSnapshot.data() as Map<String, dynamic>;
      final items = cartData['items'] ?? {};

      // Update _addedToCart to reflect items
      setState(() {
        _addedToCart.clear();
        items.forEach((medicineId, _) {
          _addedToCart.add(medicineId);
        });
      });
    }
  }

  // When search input changes, update the medicines list
  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      medicines = fetchMedicines(_searchTerm); // Update medicines list
    });
  }

  void _addToCart(Medicine medicine) async {
    if (widget.userId == null) {
      print('Error: User ID is null');
      return;
    }
    setState(() {
      _isAddingToCart[medicine.id] = true; // Start loading when adding to cart
    });

    final cartCollection = FirebaseFirestore.instance.collection('Carts');
    final cartDoc = cartCollection.doc(widget.userId);

    try {
      final cartSnapshot = await cartDoc.get();
      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        final items = cartData['items'] ?? {};

        // Add medicine to the cart without changing quantity
        await cartDoc.update({
          'items.${medicine.id}': {
            'name': medicine.name,
            'price': medicine.price,
          }
        });
      } else {
        await cartDoc.set({
          'items': {
            medicine.id: {
              'name': medicine.name,
              'price': medicine.price,
            }
          }
        });
      }

      setState(() {
        _addedToCart.add(medicine.id); // Mark as added
        _isAddingToCart[medicine.id] =
            false; // Stop loading after adding to cart
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} added to cart!'),
          duration: const Duration(seconds: 2),
        ),
      );
      print('${medicine.name} added to cart');
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  void _removeFromCart(Medicine medicine) async {
    if (widget.userId == null) {
      print('Error: User ID is null');
      return;
    }
    setState(() {
      _isAddingToCart[medicine.id] =
          true; // Start loading when removing from cart
    });

    final cartCollection = FirebaseFirestore.instance.collection('Carts');
    final cartDoc = cartCollection.doc(widget.userId);

    try {
      final cartSnapshot = await cartDoc.get();
      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        final items = cartData['items'] ?? {};

        // Remove medicine from cart
        await cartDoc.update({
          'items.${medicine.id}': FieldValue.delete(),
        });
      }

      setState(() {
        _addedToCart.remove(medicine.id); // Remove from added items
        _isAddingToCart[medicine.id] =
            false; // Stop loading after removing from cart
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} removed from cart!'),
          duration: const Duration(seconds: 2),
        ),
      );
      print('${medicine.name} removed from cart');
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  void _goToCart() async {
    // Push to the Cart screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cart(userId: widget.userId),
      ),
    );

    // After returning, check if result is not null, meaning cart was updated
    if (result != null && result == 'updated') {
      // Refresh medicines if necessary
      setState(() {
        medicines = fetchMedicines(_searchController.text); // Refresh medicines
        fetchCart(); // Refresh cart data after update
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: const Text(
          'Pharmacy',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter medicine name',
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
                  controller: _searchController,
                  onChanged: (text) {
                    _onSearchChanged(text);
                  }),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: medicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No medicines found.'));
                } else {
                  final medicinesList = snapshot.data!;
                  return ListView.builder(
                      itemCount: medicinesList.length,
                      itemBuilder: (context, index) {
                        final medicine = medicinesList[index];
                        final isAdded = _addedToCart.contains(medicine.id);
                        final isLoading = _isAddingToCart[medicine.id] ?? false;

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align items to the top
                              children: [
                                // Column for the medicine info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Price: EGP ${medicine.price.toStringAsFixed(2)}\nDosage: ${medicine.dosage}',
                                      ),
                                    ],
                                  ),
                                ),
                                // Column for the icons
                                Column(
                                  children: [
                                    IconButton(
                                      iconSize: 24,
                                      padding: EdgeInsets
                                          .zero, // Remove internal padding
                                      icon: isLoading
                                          ? CircularProgressIndicator(
                                              color: Color(0xff39c4c9))
                                          : Icon(
                                              isAdded ? Icons.check : Icons.add,
                                              color: isAdded
                                                  ? Color(0xff39c4c9)
                                                  : null,
                                            ),
                                      onPressed: () {
                                        if (isAdded) {
                                          _removeFromCart(
                                              medicine); // Remove if already in cart
                                        } else if (_isAddingToCart[
                                                medicine.id] !=
                                            true) {
                                          _addToCart(
                                              medicine); // Add if not in cart
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 16.0), // Adds some spacing from the bottom edge
        child: Align(
          alignment:
              Alignment.bottomRight, // Places the button at the bottom-right
          child: FloatingActionButton(
            backgroundColor: Color(0xff39c4c9),
            onPressed: _goToCart,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
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

class Medicine {
  final String id;
  final String name;
  final double price;
  final String dosage;

  Medicine(
      {required this.id,
      required this.name,
      required this.price,
      required this.dosage});

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      price: (data['price'] as num).toDouble(),
      dosage: data['dosage'] ?? 'Unknown',
    );
  }
}
