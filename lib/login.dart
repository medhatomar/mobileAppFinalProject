// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:mobile_app_final/signup.dart';
import 'homepage.dart';

class logIn extends StatefulWidget {
  const logIn({super.key});

  @override
  State<logIn> createState() => _logInState();
}

class _logInState extends State<logIn> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => homePage()),
                  );
                },
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff39c4c9),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New to our app? '),
              GestureDetector(
                onTap: () {
                  // Navigate to the login page (Replace `LoginPage` with your actual login screen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (Context) => signUp()),
                  );
                },
                child: Text(
                  'SignUp',
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
    );
  }
}
