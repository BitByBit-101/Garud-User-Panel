import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF17203A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: ProfileScreen(),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  bool _isEditing = false;
  String? _userId; // Variable to store the user's ID
  String? _gender;
  String? _userName;
  @override
  void initState() {
    super.initState();
    getCurrentUserId(); // Fetch user ID when the widget is initialized
  }

  Future<void> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid; // Store the user's UID
      });
      fetchProfileData(); // Fetch profile data after getting the UID
    } else {
      print("No user is currently logged in.");
    }
  }

  Future<void> fetchProfileData() async {
    if (_userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users') // Your collection name
          .doc(_userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        _userName = data?['Name'] ?? '';
        nameController.text = _userName!;
        // designationController.text = data?['designation'] ?? '';
        emailController.text = data?['email'] ?? '';
        phoneController.text = data?['Phone_no'] ?? '';
        // genderController.text = data?['gender'] ?? '';
        _gender = data?['gender'] ?? '';
        genderController.text = _gender ?? '';
        setState(() {});
      }
    }
  }

  // Function to save user profile data to Firestore
  Future<void> saveProfileData() async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection('Users').doc(_userId).update({
        'Name': nameController.text,
        // 'designation': designationController.text,
        'Phone_no': phoneController.text,
        // 'gender': genderController.text,
        'gender': _gender ?? genderController.text,
      });
      print("Profile updated successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4FA),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF17203A),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: Image.network(
                      '', // Replace with an actual URL if available
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _userName ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17203A),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildCurvedTextField(
                      'Full Name',
                      nameController,
                      Icons.person,
                      isEditable: _isEditing,
                    ),
                    buildDivider(),
                    buildCurvedTextField(
                        'Designation', designationController, Icons.work,
                        isEditable: _isEditing),
                    buildDivider(),
                    buildCurvedTextField('Email', emailController, Icons.email,
                        isEditable: false),
                    buildDivider(),
                    buildCurvedTextField(
                        'Phone Number', phoneController, Icons.phone,
                        isEditable: _isEditing),
                    buildDivider(),
                    _buildGenderField(),
                    // buildCurvedTextField('Gender', genderController, Icons.male,
                    //     isEditable: _isEditing),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
                label: Text(
                  _isEditing ? 'Save Changes' : 'Edit Profile',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17203A),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      saveProfileData();
                      print(
                          "Saved: ${nameController.text}, ${designationController.text}");
                    }
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    // If gender is already fetched and not empty
    if (_gender != null && _gender!.isNotEmpty) {
      // If not in editing mode, show the gender in a non-editable curved text box
      if (!_isEditing) {
        genderController.text = _gender!; // Set the gender to display
        return buildCurvedTextField(
          'Gender',
          genderController,
          Icons.male, // You can change this to any icon you'd like
          isEditable: false, // Make it non-editable
        );
      }
    }

    // If gender is empty or null, show the gender selection options (Male/Female) only in editing mode
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Text(
              'Gender',
              style: TextStyle(fontSize: 16, color: Color(0xFF17203A)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderOption('Male'),
                const SizedBox(width: 20),
                _buildGenderOption('Female'),
              ],
            ),
          ],
        ),
      );
    }

    // If not editing and gender is not set, hide the gender field
    return Container();
  }

  Widget _buildGenderOption(String gender) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _gender == gender ? const Color(0xFF17203A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          gender,
          style: TextStyle(
            color: _gender == gender ? Colors.white : const Color(0xFF17203A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildCurvedTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isEditable = true, Color iconColor = Colors.blueAccent}) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: iconColor),
          border: InputBorder.none,
        ),
        style: TextStyle(color: isEditable ? const Color(0xFF17203A) : Colors.grey),
      ),
    );
  }

  //  for gender

  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Color(0xFF17203A), thickness: 1.2),
    );
  }
}

  //  for gender
