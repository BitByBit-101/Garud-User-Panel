import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginScreenState createState() => LoginScreenState(); // Changed here
}

class LoginScreenState extends State<Login> {
  // Changed here
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for password
  bool _isEmailValid = false;
  bool _isPasswordEntered = false; // Track if the password is entered
  bool _isHovered = false;
  bool _isPressed = false;
  bool _showInvalidEmailIcon =
      false; // Track if the invalid email icon should show
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose(); // Dispose password controller
    super.dispose();
  }

  Future<void> _login() async {
    if (_isEmailValid && _isPasswordEntered) {
      try {
        // Attempt to sign in the user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Navigate to home page on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(
              title: 'Home',
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.code);
      }
    }
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const HomePage(
    //       title: 'Home',
    //     ),
    //   ),
    // );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                'Hello\nSign in!',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Scrollable content with white background
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            TextField(
                              focusNode: _emailFocusNode,
                              onTap: () {
                                _emailFocusNode.requestFocus();
                              },
                              controller: _emailController,
                              onChanged: (value) {
                                setState(() {
                                  _isEmailValid =
                                      value.endsWith('iitmandi.ac.in');
                                  // Show the cross mark only when the email is invalid and non-empty
                                  _showInvalidEmailIcon =
                                      value.isNotEmpty && !_isEmailValid;
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                suffixIcon: _showInvalidEmailIcon
                                    ? const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      )
                                    : null, // No cross mark when the email is valid or empty
                                label: const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              onChanged: (value) {
                                setState(() {
                                  _isPasswordEntered = value.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
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
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Color(0xff281537),
                                ),
                              ),
                            ),
                            const SizedBox(height: 70),

                            // Animated Sign In Button with hover and click effects
                            GestureDetector(
                              onTapDown: (details) {
                                setState(() {
                                  _isPressed = true;
                                });
                              },
                              onTapUp: (details) {
                                setState(() {
                                  _isPressed = false;
                                  _login();
                                });
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
                                cursor: (_isEmailValid && _isPasswordEntered)
                                    ? SystemMouseCursors.click
                                    : SystemMouseCursors.forbidden,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  height: _isPressed ? 50 : 55,
                                  width: _isPressed ? 290 : 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient:
                                        (_isEmailValid && _isPasswordEntered)
                                            ? LinearGradient(
                                                colors: _isHovered
                                                    ? [
                                                        const Color(0xff000000),
                                                        const Color(0xff1F0E27),
                                                      ]
                                                    : [
                                                        const Color(0xff000000),
                                                        const Color(0xff000000),
                                                      ],
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Colors.grey,
                                                  Colors.grey,
                                                ],
                                              ),
                                    boxShadow: _isHovered
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black38,
                                              offset: Offset(0, 6),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Sign-up text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Signup(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign up",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int hexColor(String c) {
  String sColor = '0xff$c';
  sColor = sColor.replaceAll('#', '');
  int dColor = int.parse(sColor);
  return dColor;
}
