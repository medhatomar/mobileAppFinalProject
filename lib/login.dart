import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';
import 'signup.dart';

class logIn extends StatefulWidget {
  const logIn({super.key});

  @override
  State<logIn> createState() => _logInState();
}

class _logInState extends State<logIn> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  int selectedIndex = 0; 
  bool userNotFound = false; 

  Future<void> signinUser() async {
    setState(() {
      isLoading = true; // Start loading when user creation begins
    });
    try {
      final input = inputController.text.trim();
      final password = passwordController.text.trim();

      QuerySnapshot query;

      // Check Firestore for the user based on the selected index (Email or Username)
      if (selectedIndex == 0) {
        // Email login
        query = await firestore
            .collection('Users')
            .where('email', isEqualTo: input)
            .get();
      } else {
        // Username login
        query = await firestore
            .collection('Users')
            .where('username', isEqualTo: input)
            .get();
      }

      if (query.docs.isEmpty) {
        // User not found
        setState(() {
          userNotFound = true;
        });
        return;
      } else {
        setState(() {
          userNotFound = false;
        });
      }

      // Retrieve user data (since we know the user exists now)
      final userDoc = query.docs.first;

      if (selectedIndex == 0) {
        // Email login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: input,
          password: password,
        );
      } else if (selectedIndex == 1) {
        // Username login (assuming email is associated with username)
        final storedEmail = userDoc['email'];
        final storedPassword = password;

        if (storedPassword != password) {
          setState(() {
            userNotFound = true;
          });
          return;
        }

        // Proceed with email/password authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: storedEmail,
          password: password,
        );
      }

      // Navigate to homePage after successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => homePage()),
      );
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      setState(() {
        userNotFound = true; // Show error if there's an auth issue
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        userNotFound = true; // Show error in case of other issues
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading after operation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: AssetImage('assets/images/CuraSyncLogo.png'),
              width: 300,
              height: 300,
            ),
          ),
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
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Toggle buttons for selection
                ToggleButtons(
                  isSelected: [
                    selectedIndex == 0,
                    selectedIndex == 1,
                  ],
                  onPressed: (index) {
                    setState(() {
                      selectedIndex = index;
                      inputController.clear(); // Clear the input field
                      passwordController.clear();
                      userNotFound = false; // Reset error state
                    });
                  },
                  borderRadius: BorderRadius.circular(50),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xff39c4c9),
                  color: const Color(0xffa9a9a9),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text("Email"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text("Username"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Render the appropriate input field
                if (selectedIndex == 0)
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 15.0),
                      enabledBorder: OutlineInputBorder(
                       borderSide: BorderSide(
                          color: userNotFound ? Colors.red : Color(0xffa9a9a9),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                       borderSide: BorderSide(
                          color: userNotFound ? Colors.red : Color(0xffa9a9a9),
                        ),

                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: 'Enter Email',
                      hintStyle: TextStyle(
                        color: Color(0xffa9a9a9),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color(0xffa9a9a9),
                      ),
                    ),
                  ),
                if (selectedIndex == 1)
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: userNotFound ? Colors.red : Color(0xffa9a9a9),),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                       borderSide: BorderSide(
                        color: userNotFound ? Colors.red : Color(0xffa9a9a9),
                      ),

                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: 'Enter Username',
                      hintStyle: TextStyle(
                        color: Color(0xffa9a9a9),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xffa9a9a9),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(
                      color: Color(0xffa9a9a9),
                    ),
                    prefixIcon: Icon(Icons.key, color: Color(0xffa9a9a9)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: userNotFound ? Colors.red : Color(0xffa9a9a9)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                     borderSide: BorderSide(
                      color: userNotFound ? Colors.red : Color(0xffa9a9a9),
                    ),

                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (userNotFound)
            Center(
              child: Text(
                "User not found",
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: signinUser,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff39c4c9),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New to our app? '),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (Context) => signUp()),
                  );
                },
                child: Text(
                  'SignUp',
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
    );
  }
}
