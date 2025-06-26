import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            // Helpline Header with Back Button
          Container(
            width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF0E1A2F), Color(0xFF34485E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
                borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const HomePage(title: 'Home'),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                      );
                    },
                ),
                  const Spacer(),
                  const Text(
                    'Get Help',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Space to balance the arrow icon
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Illustration Image
            const Icon(Icons.handshake, size: 80, color: Colors.grey),
            const SizedBox(height: 20),

            // Helper text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'We are here to help, so please get in touch with us.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4A5670),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Contact Information Section
            buildHelplineCard(
              context,
              'Phone Number',
              '8708422325',
              Icons.phone,
              Colors.blueAccent,
              onTap: () => _showCallConfirmationDialog(context, '2025550162'),
            ),
            const SizedBox(height: 20),
            buildHelplineCard(
              context,
              'E-mail Address',
              'ravi870862@gmail.com',
              Icons.email,
              Colors.orange,
              onTap: () => _launchFeedbackEmail(context),
            ),
            const SizedBox(height: 50),
        ],
      ),
      ),
    );
  }

  // Function to show call confirmation dialog
  void _showCallConfirmationDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Call'),
          content: Text('Do you want to call $phoneNumber?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Call'),
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch phone app.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to launch email app with feedback pre-filled
  void _launchFeedbackEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ravi870862@gmail.com',
      query:
      'subject=${Uri.encodeComponent('Feedback for Helpline')}&body=${Uri.encodeComponent('Please enter your feedback here...')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error launching email client.')),
      );
    }
  }

  // Helper function to create helpline cards
  Widget buildHelplineCard(
      BuildContext context,
      String title,
      String contact,
      IconData icon,
      Color iconColor, {
        required Function() onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
          boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
            CircleAvatar(
              backgroundColor: iconColor,
              radius: 25,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                  style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                    color: Color(0xFF0E1A2F),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
              Text(
                contact,
                  style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A5670),
                    decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
