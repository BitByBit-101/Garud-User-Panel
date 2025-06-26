import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome.dart'; // Assuming 'welcome.dart' is the file containing your Welcome widget

void main() async {
  // Ensure that plugin services are initialized before app startup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Run the app after the splash screen completes
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        fontFamily: 'inter', // Ensure this font is included in pubspec.yaml
        useMaterial3: true, // Enables Material 3 design components
      ),
      home: const SplashScreen(), // Custom splash screen as the entry point
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.5;
  bool _navigating = false;

@override
void initState() {
  super.initState();

  // Fade-in effect (Ease-in)
  Future.delayed(const Duration(milliseconds: 500), () {
    setState(() {
      _opacity = 1.0; // Fade-in effect
    });
  });

  // Scale up with bounce-in effect after fade-in
  Future.delayed(const Duration(seconds: 1), () {
    setState(() {
      _scale = 1.0; // Scale to full size with bounce-in effect
    });
  });

  // Navigate to the Welcome screen after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    if (!_navigating) {
      setState(() {
        _navigating = true;
      });

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700), // Slightly longer transition
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutExpo, // Slower ease-out transition
              ),
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return const Welcome(); // Transition to Welcome screen
          },
        ),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient for splash screen
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
               Color(0xFF9096B8), // A shade of light blue or greyish-blue
               Color(0xFF17203A)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Center the animated image
            Center(
              child: AnimatedOpacity(
                opacity: _opacity, // Control opacity for fade-in effect (Ease-in)
                duration: const Duration(seconds: 1), // Duration for fade-in
                curve: Curves.easeIn, // Ease-in for fade effect
                child: AnimatedScale(
                  scale: _scale, // Control scale for bounce-in effect
                  duration: const Duration(seconds: 1),
                  curve: Curves.bounceIn, // Bounce-in animation curve for entrance
                  child: Image.asset(
                    'assets/images/splash_background.png', // Replace with your splash image
                    width: 250, // Increased image size
                    height: 250,
                  ),
                ),
              ),
            ),
            // "GARUD" text at the bottom center
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50), // Adjust the padding to position it near the bottom
                child: Text(
                  'GARUD', // Text on splash screen
                  style: TextStyle(
                    fontSize: 10, // Set font size
                    fontWeight: FontWeight.w100, // Thin text style
                    color: Colors.white, // Text color
                    letterSpacing: 2.0, // Space between letters
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
// i have fluter project and I am bus booking for my college so how it looks like that there are some slots in which the buses are running like A,b,C and something upto E, and in each slot there can be some buses running means let say slot A has 2 buses running bus 1 and bus2 in this way so I want to create the firestore database for this and want to integrate in teh f 