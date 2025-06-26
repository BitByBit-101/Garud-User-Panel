import 'package:flutter/material.dart';
import 'signup.dart'; // Importing the signup page

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> {
  double _opacity = 0.0;
  double _logoPosition = 50.0;

  @override
  void initState() {
    super.initState();
    // Trigger animations after a small delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _logoPosition = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth =
              (constraints.maxWidth < 500 ? constraints.maxWidth : 400)
                  .toDouble();
          final screenHeight = constraints.maxHeight;

          return Center(
            child: SizedBox(
              width: screenWidth,
              child: Stack(
                children: [
                  // Background Gradient
                  Container(
                    height: screenHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5DE0E6),
                          Color(0xFF004AAD),Color(0xFF5DE0E6)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: screenHeight * 0.1, left: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Fade In and Slide Up Animation
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(seconds: 1),
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/iitLogo.png',
                                width: screenWidth * 0.5, // Reduced size
                                height: screenHeight * 0.15, // Reduced size
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          // Welcome Text Fade In
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(seconds: 1),
                            child: Center(
                              child: Text(
                                'Greetings, Traveller!',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF0F4FA),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content with rounded top container
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.37),
                    child: Container(
                      height: screenHeight *
                          0.63, // Fixed height to fit in the screen
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            // Title Text Fade In
                            AnimatedOpacity(
                              opacity: _opacity,
                              duration: const Duration(seconds: 1),
                              child: Text(
                                'Welcome to GARUD',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            // Bus Image Fade In and Slide Up
                            SizedBox(
                              height: screenHeight * 0.28,
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeInOut,
                                    top: _logoPosition,
                                    left: screenWidth * 0.15,
                                    child: AnimatedOpacity(
                                      opacity: _opacity,
                                      duration: const Duration(seconds: 1),
                                      child: Image.asset(
                                        "assets/images/buslogo.jpg",
                                        width: screenWidth * 0.7,
                                        height: screenHeight * 0.22,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Introductory Text and Button
                            SizedBox(height: screenHeight * 0.04),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: AnimatedOpacity(
                                opacity: _opacity,
                                duration: const Duration(seconds: 1),
                                child: Text(
                                  'Ready to ride? \n Tap to Begin ',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            // 'Get Started' Button
                            AnimatedOpacity(
                              opacity: _opacity,
                              duration: const Duration(seconds: 1),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Signup(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final fadeAnimation =
                                            Tween(begin: 0.0, end: 1.0)
                                                .animate(animation);
                                        final slideAnimation = Tween(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation);

                                        return SlideTransition(
                                          position: slideAnimation,
                                          child: FadeTransition(
                                            opacity: fadeAnimation,
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.18,
                                    vertical: screenHeight * 0.025,
                                  ),
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
