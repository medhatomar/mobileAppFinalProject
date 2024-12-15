// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import
import 'package:mobile_app_final/PurchaseSuccessfulPage.dart';
import 'package:mobile_app_final/activity.dart';
import 'package:mobile_app_final/homepage.dart';
import 'package:mobile_app_final/myprofile.dart';

class Payment extends StatefulWidget {
  final double totalCost; // Receive totalCost as a parameter

  const Payment({super.key, required this.totalCost});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedCity;
  String? _shippingMethod;
  String? _paymentMethod;
  double _shippingPrice = 0.0;
  double _total = 0.0;
  final List<String> _cities = [
    "Cairo",
    "Alexandria",
    "Giza",
    "Luxor",
    "Aswan",
    "Suez",
    "Port Said",
    "Hurghada"
  ];
  final List<String> _shippingMethods = ["Standard", "Express"];
  final List<String> _paymentMethods = ["Credit Card", "Cash on Delivery"];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormSubmitted = false; // Track if the form has been submitted

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _firstNameController.addListener(() {
      if (_isFormSubmitted) {
        _formKey.currentState?.validate();
      }
    });
    _lastNameController.addListener(() {
      if (_isFormSubmitted) {
        _formKey.currentState?.validate();
      }
    });
    _addressController.addListener(() {
      if (_isFormSubmitted) {
        _formKey.currentState?.validate();
      }
    });
  }

  void _removeValidationError() {
    setState(() {});
    _formKey.currentState?.validate();
  }

  @override
  void dispose() {
    // Don't forget to dispose the controllers when done
    _firstNameController.dispose();
    _lastNameController.dispose();

    _addressController.dispose();

    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            // Ensure that the email is set to _emailController
            _phoneController.text = userDoc['phoneNumber'] ?? "Unknown Phone";
            _countryController.text = 'Egypt'; // Fixed and read-only
            // _selectedCity = userDoc['city'] ?? _cities.first;
            // _addressController.text = userDoc['address'] ?? "Unknown Address";
            _emailController.text = userDoc['email'] ??
                currentUser.email ??
                "Unknown email"; // Fetch email
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Calculate the shipping cost
  double _calculateShippingCost() {
    if (_shippingMethod == 'Standard') {
      return 60.0;
    } else if (_shippingMethod == 'Express') {
      return 80.0;
    }
    return 0; // Default to 0 if no shipping method selected
  }

  double _calculateTotalCost() {
    if (_shippingMethod == 'Standard') {
      return widget.totalCost + 60.0;
    } else if (_shippingMethod == 'Express') {
      return widget.totalCost + 80.0;
    }
    return widget.totalCost; // Default to 0 if no shipping method selected
  }

  // Calculate the final total
  double _calculateFinalTotal() {
    double shippingCost = _calculateShippingCost();
    return _total + shippingCost;
  }

  // Submit form function
  // Inside your _submitForm method:

  void _submitForm() {
    setState(() {
      _isFormSubmitted = true; // Mark the form as submitted
    });
    if (_formKey.currentState?.validate() ?? false) {
      if (_shippingMethod == null) {
        // Show an error message if no shipping method is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a shipping method')),
        );
        return; // Stop further execution if no shipping method is selected
      }

      setState(() {
        // Show loading on the button if Cash on Delivery is selected
        _isLoading = true;
      });

      // If "Cash on Delivery" is selected
      if (_paymentMethod == 'Cash on Delivery') {
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            _isLoading = false; // Stop loading after delay
          });

          // Navigate to the success page with checkmark
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseSuccessfulPage(),
            ),
          );
        });
      }
      // If "Credit Card" is selected
      else if (_paymentMethod == 'Credit Card') {
        _showCreditCardDialog();
      }
    } else {
      print("Form is invalid, please fill all fields.");
    }
  }

// Add the loading state variable
  bool _isLoading = false;
  void _showCreditCardDialog() {
    TextEditingController _cardNumberController = TextEditingController();
    TextEditingController _expiryDateController = TextEditingController();
    TextEditingController _cvvController = TextEditingController();
    TextEditingController _cardHolderController = TextEditingController();

    // Regular expressions for validation
    final _cardNumberRegex = RegExp(r'^\d{4} \d{4} \d{4} \d{4}$');
    final _expiryDateRegex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    final _cvvRegex = RegExp(r'^\d{3}$');

    // Flags to track the validity of each field
    bool _isCardNumberValid = true;
    bool _isExpiryDateValid = true;
    bool _isCVVValid = true;
    bool _isCardHolderValid = true;

    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Credit Card Info'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card Number
                      TextField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          hintText: 'Card Number',
                          errorText: !_isCardNumberValid
                              ? 'Invalid card number'
                              : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff39c4c9)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          value = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (value.length <= 16) {
                            _cardNumberController.text = value.replaceAllMapped(
                                RegExp(r"(\d{4})(?=\d)"),
                                (match) => "${match.group(1)} ");
                            _cardNumberController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _cardNumberController.text.length),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      // Card Holder
                      TextField(
                        controller: _cardHolderController,
                        decoration: InputDecoration(
                          hintText: 'Card Holder Name',
                          errorText: !_isCardHolderValid
                              ? 'Card holder name is required'
                              : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff39c4c9)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Expiry Date
                      TextField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          hintText: 'Expiry Date (MM/YY)',
                          errorText: !_isExpiryDateValid
                              ? 'Invalid expiry date format'
                              : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff39c4c9)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          value = value.replaceAll(RegExp(r'[^0-9/]'), '');
                          if (value.length == 2 && !value.contains('/')) {
                            value += '/';
                          } else if (value.length > 5) {
                            value = value.substring(0, 5);
                          }
                          _expiryDateController.value = TextEditingValue(
                            text: value,
                            selection:
                                TextSelection.collapsed(offset: value.length),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      // CVV
                      TextField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          hintText: 'CVV',
                          errorText:
                              !_isCVVValid ? 'CVV should be 3 digits' : null,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff39c4c9)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          value = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (value.length <= 3) {
                            _cvvController.text = value;
                            _cvvController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: _cvvController.text.length),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Validate fields
                          setState(() {
                            _isCardNumberValid = _cardNumberRegex
                                .hasMatch(_cardNumberController.text);
                            _isExpiryDateValid = _expiryDateRegex
                                .hasMatch(_expiryDateController.text);
                            _isCVVValid =
                                _cvvRegex.hasMatch(_cvvController.text);
                            _isCardHolderValid =
                                _cardHolderController.text.isNotEmpty;
                          });

                          // If all fields are valid, proceed
                          if (_isCardNumberValid &&
                              _isExpiryDateValid &&
                              _isCVVValid &&
                              _isCardHolderValid) {
                            setState(() => _isLoading = true);

                            // Simulate payment processing and navigate
                            Future.delayed(Duration(seconds: 2), () {
                              setState(() => _isLoading = false);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PurchaseSuccessfulPage(),
                                ),
                              );
                            });
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Submit Payment',
                          style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff39c4c9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Contact" subtitle and Email field
                Text(
                  'Contact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  style: TextStyle(color: Colors.grey),
                  controller: _emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xff39c4c9),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }

                    return null;
                  },
                  readOnly: true,
                ),

                SizedBox(height: 16),

                // "Delivery" subtitle and form fields
                Text(
                  'Delivery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffa9a9a9)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffa9a9a9)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffa9a9a9)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffa9a9a9)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),
                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

                // apt
                TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Apartment, suite, etc. (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                SizedBox(height: 15),
                // City Dropdown
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor:
                        Colors.white, // Background color of the dropdown menu
                    cardTheme: CardTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffa9a9a9)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffa9a9a9)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    value: _selectedCity,
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue;
                        // Trigger form validation to update the error state
                        _formKey.currentState?.validate();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a city'; // This shows the error if no city is selected
                      }
                      return null; // This removes the error when a city is selected
                    },
                  ),
                ),

                SizedBox(height: 15),

                // Country
                TextFormField(
                  style: TextStyle(color: Colors.grey),
                  controller: _countryController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Postal code (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // Phone Number
                TextFormField(
                  style: TextStyle(color: Colors.grey),
                  controller: _phoneController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                Text('Shipping Method',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Column(
                    children: _shippingMethods.map((method) {
                      String price = "";
                      String subtext = "";
                      switch (method) {
                        case "Standard":
                          price = "\EGP 60.00";
                          subtext = "Delivery in 3-5 business days";
                          break;
                        case "Express":
                          price = "\EGP 80.00";
                          subtext = "Same day delivery";
                          break;
                        default:
                          price = "\$0.00";
                          subtext = "";
                      }
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Space between method and price
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method), // Shipping method name
                                if (subtext
                                    .isNotEmpty) // Only show subtext if it's not empty
                                  Text(
                                    subtext,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors
                                            .grey), // Small font for subtext
                                  ),
                              ],
                            ),
                            Text(price,
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold)), // Price for the method
                          ],
                        ),
                        leading: Radio<String>(
                          activeColor: Color(0xff39c4c9),
                          value: method,
                          groupValue: _shippingMethod,
                          onChanged: (String? value) {
                            setState(() {
                              _shippingMethod = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 16),

                // Payment Method Section
                Text('Payment Method',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Column(
                    children: _paymentMethods.map((method) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<String>(
                              activeColor: Color(0xff39c4c9),
                              value: method,
                              groupValue: _paymentMethod,
                              onChanged: (String? value) {
                                setState(() {
                                  _paymentMethod = value;
                                });
                              },
                            ),
                            Text(method),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'EGP ${widget.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'EGP ${_calculateShippingCost().toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'EGP ${_calculateTotalCost().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate the form first
                      if (_formKey.currentState?.validate() ?? false) {
                        // Check if a payment method is selected
                        if (_paymentMethod == null || _paymentMethod!.isEmpty) {
                          // Show an error if no payment method is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please select a payment method')),
                          );
                          return; // Stop the function if no payment method is selected
                        }

                        // Check if a shipping method is selected (radio buttons)
                        if (_shippingMethod == null ||
                            _shippingMethod!.isEmpty) {
                          // Show an error if no shipping method is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please select a shipping method')),
                          );
                          return; // Stop the function if no shipping method is selected
                        }

                        setState(() {
                          _isLoading =
                              true; // Show loading when validation passes
                        });

                        // Simulate some delay for loading (e.g., network request)
                        await Future.delayed(
                            Duration(seconds: 2)); // Simulate loading process

                        // Now check payment method and proceed with the appropriate action
                        if (_paymentMethod == "Cash on Delivery") {
                          setState(() {
                            _isLoading = false; // Stop loading after processing
                          });

                          // Navigate to the success page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PurchaseSuccessfulPage(), // Replace with your success page
                            ),
                          );
                        } else if (_paymentMethod == "Credit Card") {
                          setState(() {
                            _isLoading = false; // Stop loading after processing
                          });
                          // Show credit card dialog
                          _showCreditCardDialog();
                        } else {
                          // Handle unexpected payment method case (shouldn't reach here)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Invalid payment method selected')),
                          );
                          setState(() {
                            _isLoading =
                                false; // Stop loading after showing the error
                          });
                        }
                      } else {
                        // If the form is invalid, show a message and stop loading
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please fill all required fields')),
                        );
                      }
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Complete Purchase',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Color(0xff39c4c9),
                      shadowColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
