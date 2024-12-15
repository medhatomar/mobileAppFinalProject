import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; 
import 'login.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isValidUsername = true;
  String usernameErrorMessage = '';
  bool usernameExists = false;
  bool typomail=false;
  bool isValidEmail = true;
  bool redmail = true;
  String emailErrorMessage = 'Please enter a valid email address';
  String phoneErrorMessage = 'Please enter a valid phone number'; 
  bool passwordsMatch = true;
  String passwordErrorMessage = 'Passwords do not match';
  bool isLoading = false;
  bool isNum = true;
  bool rednum = true;
  
  bool hasStartedTypingInConfirmPassword = false;
  
  String selectedCountryCode = "+20";
  bool isPasswordValid = true;
  String passwordValidationErrorMessage = 'Password must contain at least one uppercase letter, one digit, and one special character.';

  void clearForm() {
  setState(() {
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    
    // Reset validation states
    redmail = true;
    rednum = true;
    isValidEmail = true;
    isPasswordValid = true;
    passwordsMatch = true;
    formIsValid = false;

    // Reset error messages
    emailErrorMessage = '';
    passwordErrorMessage = '';
    passwordValidationErrorMessage = '';
    usernameErrorMessage = '';
  });
}


  bool validateEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );

  final validDomains = ['gmail.com', 'yahoo.com', 'outlook.com'];

  // Check if the email matches the general pattern
  if (!emailRegex.hasMatch(email)) {
    return false;
  }

  // Extract the domain and convert it to lowercase for case-insensitive check
  final domain = email.split('@').last.toLowerCase();
  
  // Check if the domain is in the valid domains list
  return validDomains.contains(domain);
}



  void onEmailChanged() {
  setState(() {
    if (validateEmail(emailController.text.trim())) {
      isValidEmail = true;
      redmail = true;
      emailErrorMessage = '';
    } else {
      isValidEmail = false;
      redmail = false;
      emailErrorMessage = "Please enter a valid email address";
    }
  });
}


  bool validatePhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10;
  }

  void onPhoneChanged() {
    
    setState(() {
      if (validatePhoneNumber(phoneController.text.trim())) {
        isNum = true;
        rednum=true;
        phoneErrorMessage = ''; 
      } else {
        isNum = false;
        rednum=false;
        phoneErrorMessage = 'Invalid phone number';
      }
    });
  }
 bool validateUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]{3,15}$');
    return usernameRegex.hasMatch(username);
  }

  Future<void> checkUsernameAvailability(String username) async {
    // Check if the username is empty
    if (username.isEmpty) {
      setState(() {
        isValidUsername = false;
        usernameErrorMessage = 'Username cannot be empty';
      });
      return;
    }

    // Validate the format of the username
    if (!validateUsername(username)) {
      setState(() {
        isValidUsername = false;
        usernameErrorMessage = 'Username can only contain letters, digits, underscores, and periods';
      });
      return;
    }

    // Check if the username already exists in Firestore
    try {
      var snapshot = await firestore.collection('Users').where('username', isEqualTo: username).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          isValidUsername = false;
          usernameErrorMessage = 'Username already exists';
        });
      } else {
        setState(() {
          isValidUsername = true;
          usernameErrorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        isValidUsername = false;
        usernameErrorMessage = 'Error checking username availability';
      });
    }
  }

  
  void onUsernameChanged() {
    setState(() {
      final username = usernameController.text.trim();
      checkUsernameAvailability(username);
    });
  }
  

  void onPasswordChanged() {
    setState(() {
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Check if passwords match
      if (hasStartedTypingInConfirmPassword) {
        if (password == confirmPassword) {
          passwordsMatch = true;
          passwordErrorMessage = '';
        } else {
          passwordsMatch = false;
          passwordErrorMessage = 'Passwords do not match';
        }
      }

      bool validatePassword(String password) {
        // Regular expression: At least one uppercase letter, one digit, one special character
        final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]+$');
        
        // Check if the password matches the regex
        if (passwordRegex.hasMatch(password)) {
          // Check if password is more than 6 characters long
          if (password.length <= 6) {
            setState(() {
              passwordValidationErrorMessage = 'Password must be longer than 6 characters.';
            });
            return false;
          }
          // If the password is valid, clear the error message
          setState(() {
            passwordValidationErrorMessage = '';
          });
          return true;
        } else {
          setState(() {
            passwordValidationErrorMessage = 'Password must contain at least one uppercase letter, one digit, and one special character.';
          });
          return false;
        }
      }

      // Validate password complexity and length
      if (validatePassword(password)) {
        isPasswordValid = true;
        passwordValidationErrorMessage = '';
      } else {
        isPasswordValid = false;
      }
    });
    
  }





Future<void> createUser() async {
  setState(() {
    isLoading = true; // Start loading when user creation begins
  });

  // Define your email and other variables at the start of the function
  final email = emailController.text.trim(); // Extract email here
  final username = usernameController.text.trim();
  final password = passwordController.text.trim();

  try {
    // Try to create the user
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Continue user creation flow
    final String uid = userCredential.user!.uid;
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': "$selectedCountryCode ${phoneController.text.trim()}",
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('You have been registered successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => logIn()), // Navigate to login screen
              );
            },
            child: Text('Go to Login', style: TextStyle( color: Color(0xff39c4c9),),),
          ),
        ],
      ),
    );
  } on FirebaseAuthException catch (e) {
    // Check for 'email-already-in-use' error
    if (e.code == 'email-already-in-use') {
      // Query Firestore for the username associated with this email
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email) // Use the email variable here
          .get();

      if (query.docs.isNotEmpty) {
        final username = query.docs.first['username'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email Already in Use'),
            content: Text('The email "$email" is already associated with the username "$username". Is this you?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => logIn()), // Navigate to login screen
                  );
                },
                child: Text('Yes',style: TextStyle(color: Color(0xff39c4c9) )),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('No',style: TextStyle(color: Color(0xff39c4c9) )),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('The email "$email" is already in use, but no associated username was found.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Handle other FirebaseAuthException errors
      print("Firebase Auth Exception: ${e.message}");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.message ?? 'An unknown error occurred.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color(0xff39c4c9) ),),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // General error handling
    print("Error: $e");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Something went wrong. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK',style: TextStyle(color: Color(0xff39c4c9) )),
          ),
        ],
      ),
    );
  } finally {
    setState(() {
      isLoading = false; // Stop loading after operation
    });
  }
}


bool formIsValid = true; // Flag to track form validity

void validateAndNavigate() async {
  final password = passwordController.text;
  final username = usernameController.text.trim();
  final phone = phoneController.text.trim();
  final confirmPassword = confirmPasswordController.text;
  final email = emailController.text.trim();

  final bool _isValidEmail = EmailValidator.validate(email);
  bool isValidForm = true; // This will track if the form is valid.

  // Reset error messages
  setState(() {
    rednum = true;
    redmail = true;
    passwordErrorMessage = '';
    emailErrorMessage = '';
    passwordValidationErrorMessage = '';
    formIsValid = true;
  });

  // Phone validation
  if (phone.isEmpty || !isNum) {
    setState(() {
      rednum = false;
      formIsValid = false; // Disable button if phone number is invalid
    });
    return; // Stop further validation if phone is invalid
  }

  // Email validation
  if (!validateEmail(email)) {
    setState(() {
      isValidEmail = false;
      redmail = false;
      emailErrorMessage = "Please enter a valid email address";
      formIsValid = false; // Disable form if email is invalid
    });
    return; // Stop further validation
  }
  // Password fields cannot be empty
  if (password.isEmpty || confirmPassword.isEmpty) {
    setState(() {
      formIsValid = false; // Disable button if passwords are empty
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password fields cannot be empty.')),
    );
    return;
  }

  // Ensure passwords match
  if (password != confirmPassword) {
    setState(() {
      passwordErrorMessage = 'Passwords do not match';
      formIsValid = false; // Disable button if passwords don't match
    });
    return; // Stop further validation if passwords don't match
  }

  // Ensure password meets the required criteria
  if (!isPasswordValid) {
    setState(() {
      passwordValidationErrorMessage =
          'Password must contain at least one uppercase letter, one digit, and one special character.';
      formIsValid = false; // Disable button if password is invalid
    });
    return; // Stop further validation if password doesn't meet criteria
  }

  // If everything is valid, proceed to user creation
  if (formIsValid) {
    try {
      // Call your method to create the user
      await createUser();
      clearForm();
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/CuraSyncLogo.png',
                width: 300,
                height: 150,
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Color(0xff39c4c9),
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Please login or sign up',
                    style: TextStyle(
                      color: Color(0xffa9a9a9),
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
              child: Column(
                children: [
                  TextField(
                          controller: usernameController,
                          onChanged: (value) => onUsernameChanged(), 
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide( 
                               color: (isValidUsername)? Color(0xffa9a9a9) : Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:(isValidUsername)? Color(0xffa9a9a9) : Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            hintText: 'Enter Username',
                            hintStyle: TextStyle(
                              color: Color(0xffa9a9a9),
                            ),
                            prefixIcon: Icon(Icons.person, color: Color(0xffa9a9a9)),
                          ),
                        ),
                        if(!isValidUsername)
                        Text(usernameErrorMessage, style: TextStyle(color: Colors.red),),
                        
                       
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    onChanged: (value) => onEmailChanged(), 
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                    color: redmail ? Color(0xffa9a9a9) : Colors.red, // Conditional color
                  ),
                        borderRadius: BorderRadius.circular(50),

                       
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                    color: redmail ? Color(0xffa9a9a9) : Colors.red, 
                  ),
                        borderRadius: BorderRadius.circular(50),
                        
                      ),
                      hintText: 'Enter Email',
                       hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                      prefixIcon: Icon(Icons.email, color: Color(0xffa9a9a9)),
                    ),
                  ),
                  SizedBox(height: 5,),
                  if(!redmail)
                  Text(emailErrorMessage, style: TextStyle(color: Colors.red),),
                  
                 
                    
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // Dropdown for country code
                      Container(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: selectedCountryCode,
                          items: ["+20", "+1", "+91", "+61", "+971"]
                              .map((code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCountryCode = value!;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide( color: rednum ? Color(0xffa9a9a9) : Colors.red, ),
                              borderRadius: BorderRadius.circular(50),
                              
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide( color: rednum ? Color(0xffa9a9a9) : Colors.red, ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Phone number input
                      Expanded(
                        child: TextField(
                    controller: phoneController,
                    onChanged: (value) => onPhoneChanged(), 
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                    color: rednum ? Color(0xffa9a9a9) : Colors.red, // Conditional color
                  ),
                        borderRadius: BorderRadius.circular(50),

                       
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                    color: rednum ? Color(0xffa9a9a9) : Colors.red, 
                  ),
                        borderRadius: BorderRadius.circular(50),
                        
                      ),
                      hintText: 'Enter Phone Number',
                       hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                      prefixIcon: Icon(Icons.phone, color: Color(0xffa9a9a9)),
                    ),
                  ),
                  ),
                    ],
                  ),
                  if(!rednum)
                  Text(phoneErrorMessage, style: TextStyle(color: Colors.red),),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    onChanged: (value) => onPasswordChanged(),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                       hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                      prefixIcon: Icon(Icons.key, color: Color(0xffa9a9a9)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide( color: isPasswordValid ? Color(0xffa9a9a9) : Colors.red),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide( color: isPasswordValid ? Color(0xffa9a9a9) : Colors.red),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  if (!isPasswordValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        passwordValidationErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                     onChanged: (value) {
                if (!hasStartedTypingInConfirmPassword) {
                  setState(() {
                    hasStartedTypingInConfirmPassword = true;
                  });
                }
                onPasswordChanged();
              },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                       hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                      prefixIcon: Icon(Icons.key, color: Color(0xffa9a9a9)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: passwordsMatch ? Color(0xffa9a9a9) : Colors.red), // Conditional color
                            borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(
                            color: passwordsMatch ? Color(0xffa9a9a9) : Colors.red), // Conditional color
                            borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  
                  if (!passwordsMatch)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                passwordErrorMessage,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
                ],
              ),
            ),
            Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                          
                            validateAndNavigate();
                                  
                          },
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                             backgroundColor: Color(0xff39c4c9),  // Change color when disabled
                          ),
                        ),
                      ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => logIn()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xff39c4c9),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
