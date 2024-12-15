import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';
import 'package:mobile_app_final/payment.dart';
import 'package:mobile_app_final/pharmacy.dart';
import 'package:provider/provider.dart'; // Import the provider package

class Cart extends StatelessWidget {
  final String? userId;

  const Cart({super.key, required this.userId});

  void _updateQuantity(
      String medicineId, int newQuantity, BuildContext context) async {
    final cartCollection = FirebaseFirestore.instance.collection('Carts');
    final cartDoc = cartCollection.doc(userId);

    try {
      // Update the quantity of the item in the cart
      if (newQuantity > 0) {
        await cartDoc.update({
          'items.$medicineId.quantity': newQuantity,
        });
      } else {
        await cartDoc.update({
          'items.$medicineId': FieldValue.delete(),
        });
      }

      // After updating, calculate and update the cart total
      _updateCartTotal(cartDoc);
    } catch (e) {
      print('Error updating quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }

  Future<void> _updateCartTotal(DocumentReference cartDoc) async {
    final cartSnapshot = await cartDoc.get();
    if (!cartSnapshot.exists) {
      print("No cart data found.");
      return;
    }

    final cartData = cartSnapshot.data() as Map<String, dynamic>;
    final items = cartData['items'] as Map<String, dynamic>? ?? {};

    double totalCost = 0.0;

    // Calculate the total cost of the cart
    items.forEach((key, value) {
      final quantity = value['quantity'] ?? 1;
      final price = value['price'] ?? 0.0;
      totalCost += quantity * price;
    });

    // Now update the total in Firestore
    await cartDoc.update({
      'totalCost': totalCost, // Add the total cost to Firestore
    });

    print('Updated cart total: EGP ${totalCost.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    final cartCollection = FirebaseFirestore.instance.collection('Carts');

    return Scaffold(
      backgroundColor: Color(0xfff0f4f7),
      appBar: AppBar(
        backgroundColor: Color(0xfff0f4f7),
        title: Text(
          'Cart',
          style:
              TextStyle(color: Color(0xff39c4c9), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartCollection.doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Your cart is empty.'));
          } else {
            final cartData = snapshot.data?.data() as Map<String, dynamic>;
            final items = cartData['items'] as Map<String, dynamic>? ?? {};
            if (items.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(child: Text('Your cart is empty.')),
                  SizedBox(height: 20), // Space between the text and button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pharmacy(),
                        ),
                      );
                    },
                    child: const Text(
                      'Go Back to Pharmacy',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff39c4c9), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              );
            }

            double totalCost = 0.0;

            items.forEach((key, value) {
              final quantity = value['quantity'] ?? 1;
              final price = value['price'] ?? 0.0;
              totalCost += quantity * price;
            });

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: items.entries.map((entry) {
                      final itemId = entry.key;
                      final itemData = entry.value as Map<String, dynamic>;
                      final quantity = itemData['quantity'] ?? 1;
                      final price = itemData['price'] ?? 0.0;
                      final totalPrice = price * quantity;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Medicines')
                            .doc(
                                itemId) // Assuming the medicineId is used as the document ID
                            .get(),
                        builder: (context, medicineSnapshot) {
                          if (medicineSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (!medicineSnapshot.hasData ||
                              !medicineSnapshot.data!.exists) {
                            return ListTile(
                              title: Text('Medicine not found'),
                            );
                          } else {
                            final medicineData = medicineSnapshot.data!.data()
                                as Map<String, dynamic>;
                            final dosage = medicineData['dosage'] ??
                                'N/A'; // Fetch dosage from medicine collection

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                title: Text(
                                  itemData['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price: EGP ${totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'Quantity: $quantity',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'Dosage: $dosage', // Display the dosage fetched from the medicines collection
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove,
                                      ),
                                      onPressed: () => _updateQuantity(
                                          itemId, quantity - 1, context),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _updateQuantity(
                                          itemId, quantity + 1, context),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Text(
                        'Estimated total: EGP ${totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                          height: 5), // Space between the total and subtitle
                      Text(
                        'Taxes, discounts and shipping calculated at checkout',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Colors.grey, // You can adjust the color and style
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Color(0xff39c4c9),
                          shadowColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 55),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          // Pass the totalCost to the Payment screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Payment(
                                totalCost: totalCost, // Pass the total cost
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
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
