import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'login.dart'; // Assuming you still have the login screen
import 'home.dart'; // Import your HomePage here
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _profileImage;
  bool _isEmailValid = false;
  bool _hasStartedTyping = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPressed = false;
  bool _isHovered = false;
  bool _passwordsMatch = false;

  // Function to pick an image using file picker
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _profileImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      // Handle any errors here (e.g., show a dialog)
      // print('Error picking image: $e');
    }
  }

  // Validate email function
  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.endsWith('iitmandi.ac.in') ||
          value.contains('@'); // Allow other emails for testing
    });
  }

  // Check if passwords match
  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text &&
              _passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust layout when keyboard appears
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                Color(0xFF5DE0E6),
                Color(0xFF004AAD),Color(0xFF5DE0E6)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Create Your\nAccount',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Main Body
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add a Profile Picture (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: const Color(0xff575353), width: 3),
                                ),
                                child: _profileImage != null
                                    ? ClipOval(
                                        child: Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 60,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email TextField
                        TextField(
                          controller: _emailController,
                          onChanged: (value) {
                            _validateEmail(value);
                            setState(() {
                              _hasStartedTyping = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.grey),
                            suffixIcon: _hasStartedTyping
                                ? Icon(
                                    _isEmailValid ? Icons.check : Icons.close,
                                    color: _isEmailValid
                                        ? Colors.green
                                        : Colors.red,
                                  )
                                : null,
                            label: const Text(
                              'Institute Gmail',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password TextField
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          onChanged: (value) => _checkPasswordsMatch(),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            label: const Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password TextField
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          onChanged: (value) => _checkPasswordsMatch(),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            label: const Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 70),
                        // Create Account Button
                        GestureDetector(
                          onTapDown: (details) {
                            setState(() {
                              _isPressed = true;
                            });
                          },
                          onTapUp: (details) async {
                            setState(() {
                              _isPressed = false;
                            });
                            if (_isEmailValid && _passwordsMatch) {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                String userid = userCredential.user!.uid;
                                String? downloadUrl;
                                if (_profileImage != null) {
                                  Reference ref = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'profile_images/$userid/profile.jpg');
                                  await ref.putFile(_profileImage!);
                                  downloadUrl = await ref.getDownloadURL();
                                }
                                // Create user document in Firestore
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userid)
                                    .set({
                                  'userId': userid,
                                  'email': _emailController.text,
                                  'profileImageUrl': downloadUrl,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                  'isAdmin': false, // Set this as needed
                                  'gender': '',
                                  'Phone_no': null,
                                  'Name': '',
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(
                                        title:
                                            'Home'), // Redirecting to HomePage
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          onTapCancel: () {
                            setState(() {
                              _isPressed = false;
                            });
                          },
                          child: MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                _isHovered = true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                _isHovered = false;
                              });
                            },
                            cursor: (_isEmailValid && _passwordsMatch)
                                ? SystemMouseCursors.click
                                : SystemMouseCursors.basic,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              height: _isPressed ? 50 : 55,
                              width: _isPressed ? 290 : 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: (_isEmailValid && _passwordsMatch)
                                    ? (_isHovered
                                        ? const LinearGradient(
                                            colors: [
                                              Colors
                                                  .grey, // Darker red on hover
                                              Color(
                                                  0xff1F0E27), // Darker purple on hover
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xff000000), // Custom red
                                              Color(
                                                  0xff000000), // Custom purple
                                            ],
                                          ))
                                    : const LinearGradient(
                                        colors: [
                                          Colors.grey, // Greyed-out background
                                          Colors.grey,
                                        ],
                                      ),
                              ),
                              child: Center(
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: (_isEmailValid && _passwordsMatch)
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Already have an account?
                        RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Login(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
