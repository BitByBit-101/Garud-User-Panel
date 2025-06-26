import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'profile.dart'; // Import your Profile screen
import 'notification.dart'; // Import your Notification screen
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'help_page.dart'; // Import your Home screen
import 'tickets.dart'; // Import your UserTicketsPage screen

class CustomDrawer extends StatelessWidget {
  final String? selectedItem;
  final Function(String) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Drawer(
      child: Container(
        color: const Color(0xFF17203A),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId) // Use current user's ID here
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF17203A)),
                    accountName: Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: null,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/boy.png'),
                      backgroundColor: Colors.white,
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF17203A)),
                    accountName: null,
                    accountEmail: null,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/boy.png'),
                      backgroundColor: Colors.white,
                    ),
                  );
                }

                final fullName = snapshot.data!.get('Name') ?? '';
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF17203A)),
                  accountName: fullName.isNotEmpty
                      ? Text(fullName, style: const TextStyle(color: Colors.white))
                      : null,
                  accountEmail: null,
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/boy.png'),
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
            _buildDrawerItem(
                Icons.edit_calendar_outlined, 'Ticket Booking', context),
            _buildDrawerItem(Icons.place, 'GPS', context),
            _buildDrawerItem(Icons.location_on, 'Verify Ticket', context),
            _buildDrawerItem(Icons.person, 'My Profile', context),
            _buildDrawerItem(Icons.notifications, 'Notifications', context),
            _buildDrawerItem(Icons.contact_mail, 'Help', context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    final isSelected = selectedItem == title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (title == 'My Profile') {
            _navigateToPage(context, ProfilePage());
          } else if (title == 'Notifications') {
            _navigateToPage(context, NotificationPage());
          } else if (title == 'Ticket Booking') {
            _navigateToPage(context, const HomePage(title: 'Home'));
          } else if (title == 'Help') {
            _navigateToPage(context, HelplineScreen());
          } else if (title == 'GPS') {
            _navigateToPage(context, const MapScreen());
          } else if (title == 'Verify Ticket') {
            _navigateToPage(context, const UserTicketsPage());
          }
        },
        onDoubleTap: () {
          onItemSelected(title);
          print('$title double tapped!');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: isSelected ? const Color(0xFF48CAEA) : Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? const Color(0xFF03045E) : Colors.white,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF03045E) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A helper function to handle page navigation with smooth transition
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}
