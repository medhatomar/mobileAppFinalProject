// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'login.dart';
import 'homepage.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void validateAndNavigate() {
    //final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final bool _isValid = EmailValidator.validate(emailController.text);
    //username validation still missing waiting for database........

    if (_isValid == false) {
      // Invalid email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
    } else if (password.isEmpty || confirmPassword.isEmpty) {
      // Empty passwords
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password fields cannot be empty.'),
        ),
      );
    } else if (password != confirmPassword) {
      // Password mismatch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
    } else {
      // Validation successful, navigate to SuccessScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => homePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image(
              image: AssetImage('assets/images/CuraSyncLogo.png'),
              width: 200,
              height: 200,
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 25, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                      color: Color(0xff39c4c9),
                      fontSize: 40,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 1,
                ),
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
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa9a9a9),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                            0xffa9a9a9), // Set the border color when focused
                      ),
                      borderRadius: BorderRadius.circular(
                          50), // Keep the rounded corners when focused
                    ),
                    hintText: 'Enter Username',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa9a9a9),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                            0xffa9a9a9), // Set the border color when focused
                      ),
                      borderRadius: BorderRadius.circular(
                          50), // Keep the rounded corners when focused
                    ),
                    hintText: 'Enter Email',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa9a9a9),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                            0xffa9a9a9), // Set the border color when focused
                      ),
                      borderRadius: BorderRadius.circular(
                          50), // Keep the rounded corners when focused
                    ),
                    hintText: 'Enter password',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa9a9a9),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(
                            0xffa9a9a9), // Set the border color when focused
                      ),
                      borderRadius: BorderRadius.circular(
                          50), // Keep the rounded corners when focused
                    ),
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: validateAndNavigate,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff39c4c9),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the login page (Replace `LoginPage` with your actual login screen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (Context) => logIn()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xff39c4c9), // Hyperlink color
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
    );
  }
}
