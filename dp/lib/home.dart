import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification.dart';
import 'profile.dart'; 
import 'sidebar.dart';
import 'gps.dart';
import 'help_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  HomePageState createState() => HomePageState();
}

class AvailableBusesList extends StatelessWidget {
  final List<Map<String, dynamic>> availableBuses;
  final VoidCallback onClose;
  final ValueChanged<String> onBusSelected;

  const AvailableBusesList({
    super.key,
    required this.availableBuses,
    required this.onClose,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Buses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableBuses.length,
                  itemBuilder: (context, index) {
                    String busInfo =
                        '${availableBuses[index]['busId']}'; // Example
                    return ListTile(
                      title: Text(busInfo),
                      onTap: () {
                        onBusSelected(busInfo);
                        Navigator.pop(context); // Close bottom sheet on tap
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedFromLocation = 'From';
  String _selectedToLocation = 'To';
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _selectedBusId;
  List<int> selectedSeats = [];
  final String userId =
      FirebaseAuth.instance.currentUser?.uid ?? "default_user";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selectedSeat;

  // Method to toggle the sidebar
  void toggleSidebar() {
    _scaffoldKey.currentState?.openDrawer(); // Opens the drawer using the key
  }

  Map<String, int> routeMapping = {
    'North Campus Mandi via South': 0,
    'North Campus Mandi (direct)': 1,
    'Mandi North Campus via South': 2
  };
  final List<String> _locations = ['North Campus', 'Mandi'];

  // Animation controller for notification icon
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _timeSlots = [
    '7:00 AM',
    '8:00 AM',
    '10:00 AM',
    '12:00 PM',
    '3:15 PM',
    '5:40 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateNotificationIcon() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Widget buildBusLayout(Map bookingData) {
    final List<int> availableSeats = [];
    final Map bookedSeats = bookingData['bookedSeats'];

    for (int i = 1; i <= 30; i++) {
      if (!bookedSeats.containsKey(i.toString())) {
        availableSeats.add(i);
      }
    }

    if (selectedSeat == null && availableSeats.isNotEmpty) {
      selectedSeat = availableSeats[0];
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Seat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, // Make the dropdown full-width
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: selectedSeat,
              hint: const Text("Choose a seat"),
              isExpanded: true, // Ensures full-width dropdown
              underline: const SizedBox(), // Remove the default underline
              items: availableSeats.map((seat) {
                return DropdownMenuItem<int>(
                  value: seat,
                  child: Text('Seat $seat'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  selectedSeat = newValue; // Update selected seat
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: selectedSeat != null
                  ? () {
                      // Proceed to confirm the seat booking
                      _confirmBooking(selectedSeat!);
                    }
                  : null, // Disable button if no seat is selected
              child: const Text("Confirm Booking"),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSeatSelection(int seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  void _deselectSeat(int seatNumber) {
    setState(() {
      selectedSeats.remove(seatNumber);
    });
  }

  void _showSuccessToast(String seatNumber) {
    Fluttertoast.showToast(
      msg: "Your booking for Seat $seatNumber is confirmed!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _confirmBooking(int seatNumber) {
    // Format selected date for querying
    String formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    // Query Firestore for the specific booking document
    FirebaseFirestore.instance
        .collection('Bookings')
        .where('busId', isEqualTo: _selectedBusId)
        .where('date', isEqualTo: formattedDate)
        .where('timing', isEqualTo: _selectedTimeSlot)
        .get()
        .then((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document (assuming one match for busId, date, and time)
        final document = querySnapshot.docs.first;
        int route = document['route'];
        // QR data
        String qrData =
            'Seat: $seatNumber\nBus ID: $_selectedBusId\nUser ID: $userId\nRoute: $route\nDate: $formattedDate\nTime Slot: $_selectedTimeSlot';
        final qrCodeBase64 = await generateQRCodeBase64(qrData);
        // Update the `bookedSeats` field in the Firestore document
        FirebaseFirestore.instance
            .collection('Bookings')
            .doc(document.id)
            .update({
          'bookedSeats.$seatNumber': userId,
        }).then((_) {
          FirebaseFirestore.instance
              .collection('UserBookings')
              .doc(userId)
              .set({
            'bookedSeats': FieldValue.arrayUnion([
              {
                'busId': _selectedBusId,
                'seatNo': seatNumber,
                'route': route,
                'date': formattedDate,
                'timing': _selectedTimeSlot,
                'qrCodeBase64': qrCodeBase64,
              }
            ]),
          }, SetOptions(merge: true)).then((_) {
            setState(() {
              selectedSeats.add(seatNumber); // Mark seat as booked locally
            });
            _showSuccessToast(seatNumber.toString());
          });
        }).catchError((error) {
          _showErrorDialog("Failed to update booking");
        });
      } else {
        _showErrorDialog("No matching booking found");
      }
    }).catchError((error) {
      _showErrorDialog('Error fetching booking data: $error');
    });
  }

  Widget _buildQRImage(String qrCodeBase64) {
    // Convert the base64 string back into bytes
    final bytes = base64Decode(qrCodeBase64);

    return Image.memory(
      Uint8List.fromList(bytes),
      height: 150.0, // Adjust the size as needed
      width: 150.0, // Adjust the size as needed
    );
  }

  Future<String> generateQRCodeBase64(String data) async {
    try {
      final qrCode = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      // Convert the QR code into a byte array
      final byteData = await qrCode.toImageData(300); // Size of the QR code
      final buffer = byteData!.buffer.asUint8List();

      // Convert the byte array to a base64 string
      return base64Encode(buffer);
    } catch (e) {
      print('Error generating QR code: $e');
      return '';
    }
  }

  List<String> _getFilteredLocations() {
    if (_selectedFromLocation == 'Mandi') {
      return ['North Campus via South']; // Only option when "From" is Mandi
    } else if (_selectedFromLocation == 'North Campus') {
      return [
        'Mandi via South',
        'Mandi (direct)'
      ]; // Options when "From" is North Campus
    }
    return _timeSlots;
  }

  Future<List<Map<String, dynamic>>> fetchAvailableBuses() async {
    final String route = '$_selectedFromLocation $_selectedToLocation';
    final String selectedSlot = _selectedTimeSlot ?? '';

    // Fetch buses from Firestore
    try {
      QuerySnapshot scheduleSnapshot =
          await FirebaseFirestore.instance.collection('Schedules').get();

      final List<Map<String, dynamic>> schedules = scheduleSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      final selectedRouteIndex = routeMapping[route];
      if (selectedRouteIndex == null) {
        _showErrorDialog('Invalid route selected');
        return [];
      }
      final filteredSchedules = schedules.where((schedule) {
        final mapping = schedule['mapping'] as Map<String, dynamic>?;
        // Check if the mapping exists and contains the selectedSlot with the correct route index
        return mapping != null &&
            mapping.containsKey(selectedSlot) &&
            mapping[selectedSlot] == selectedRouteIndex;
      }).toList();
      return filteredSchedules;
    } catch (e) {
      _showErrorDialog('Error fetching available buses');
      return [];
    }
  }

  void _showErrorDialog(String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error, // Error animation
      headerAnimationLoop: false,
      title: 'Error Occurred',
      desc: errorMessage,
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
      animType: AnimType.scale, // Animation type for dialog
    ).show();
  }

  // Function to show available buses in a modal bottom sheet
  void _showAvailableBuses(List<Map<String, dynamic>> availableBuses) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AvailableBusesList(
            availableBuses: availableBuses,
            onClose: () => Navigator.pop(context),
            onBusSelected: (String busId) {
              DateTime selectedDate = _selectedDate!; // Your selected date
              String selectedTimeSlot =
                  _selectedTimeSlot ?? ''; // Your selected time slot
              setState(() {
                _selectedBusId = busId;
              });
              _onBusSelected(busId, selectedDate, selectedTimeSlot);
            });
      },
    );
  }

  void _handleBusTileTap() async {
    if (_selectedTimeSlot != null) {
      List<Map<String, dynamic>> availableBuses = await fetchAvailableBuses();
      _showAvailableBuses(availableBuses);
    } else {
      _showErrorDialog('Please fill all details before selecting a bus.');
    }
  }

  Future<Map<String, dynamic>> fetchBookingData(
      String busId, DateTime selectedDate, String selectedTimeSlot) async {
    try {
      // Convert selected date to timestamp for comparison
      // Fetch bookings from Firestore where busId, date, and time match
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .where('busId', isEqualTo: busId)
          .where('date', isEqualTo: formattedDate)
          .where('timing', isEqualTo: selectedTimeSlot)
          .get();
      print(formattedDate);
      print(selectedTimeSlot);
      print(busId);
      if (querySnapshot.docs.isEmpty) {
        // If no booking exists for that time, return default data
        // return {
        //   'bookedSeats': {},
        //   'seatsAvailable': 30
        // }; // Adjust seatsAvailable as needed
        _showErrorDialog("No available buses");
      }

      // Get the first document's data (assuming only one document exists for a specific bus, date, and time)
      final bookingDoc = querySnapshot.docs.first;
      final bookedSeats = bookingDoc['bookedSeats'];
      final bookedSeatsMap = Map<String, dynamic>.from(bookedSeats);
      final seatsAvailable = bookingDoc['seatsAvailable'];

      return {'bookedSeats': bookedSeatsMap, 'seatsAvailable': seatsAvailable};
    } catch (e) {
      _showErrorDialog('Error fetching booking data');
      return {};
    }
  }

  Future<void> _bookSeat(String seatNumber) async {
    try {
      final bookingRef = FirebaseFirestore.instance
          .collection('Booking')
          .doc('your_document_id'); // Get the appropriate document ID

      // Update the bookedSeats map with the user ID for the selected seat
      await bookingRef.update({
        'bookedSeats.$seatNumber': userId,
        'seatsAvailable':
            FieldValue.increment(-1), // Decrease available seats by 1
      });

      // Refresh the seat grid after booking
      setState(() {});
    } catch (e) {
      _showErrorDialog('Error booking seat');
    }
  }

  void _handleBooking(
      String busId, DateTime selectedDate, String selectedTimeSlot) async {
    final bookingData =
        await fetchBookingData(busId, selectedDate, selectedTimeSlot);

    // Show seat grid in a bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            buildBusLayout(bookingData), // Display the seat grid
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context), // Close the booking sheet
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onBusSelected(
      String busId, DateTime selectedDate, String selectedTimeSlot) {
    _handleBooking(busId, selectedDate, selectedTimeSlot);
  }

  void _showLocationDrawer(String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select ${type == 'from' ? 'From' : 'To'} Location',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: (type == 'from')
                    ? _locations.length
                    : (_selectedFromLocation != 'From'
                        ? _getFilteredLocations().length
                        : 0),
                itemBuilder: (context, index) {
                  String locationToDisplay = (type == 'from')
                      ? _locations[index]
                      : _getFilteredLocations()[index];
                  // if (type == 'to' &&
                  //     _selectedFromLocation != 'From' &&
                  //     _locations[index] == _selectedFromLocation) {
                  //   return const SizedBox.shrink();
                  // } // Skip this location
                  return ListTile(
                    title: Text(locationToDisplay),
                    onTap: () {
                      setState(() {
                        if (type == 'from') {
                          _selectedFromLocation = locationToDisplay;
                          // Reset the To location to default when From location changes
                          _selectedToLocation = 'To'; // Reset to default
                          _selectedTimeSlot = null;
                        } else {
                          _selectedToLocation = locationToDisplay;
                          _selectedTimeSlot = null;
                        }
                      });
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    enabled: (type == 'to' && _selectedFromLocation == 'From')
                        ? false
                        : true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getAvailableTimings() {
    if (_selectedFromLocation == 'North Campus' &&
        _selectedToLocation == 'Mandi (direct)') {
      return ['5:40 PM']; // Only show this timing
    }

    // You can add more conditions here for other combinations
    return _timeSlots; // Default timings or other combinations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Color(0xFFF0F4FA)),
        ),
        backgroundColor: const Color(0xFF17203A),
        // Sidebar icon in the leading property
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/menubar.svg',
            width: 24,
            height: 24,
            color: const Color(0xFFF0F4FA), // Match the color scheme
          ),
          onPressed: toggleSidebar,
        ),
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      1.0 + _animation.value * 0.2, // Slight scaling on click
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xFFF0F4FA),
                  ),
                );
              },
            ),
            onPressed: () {
              _animateNotificationIcon();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationPage()));
              // Start the animation
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index
                as int; // Update selected index based on sidebar selection
          });
        },
        selectedItem:
            '', // You might want to replace '' with the currently selected item if needed
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.white, // Start color
            Colors.white, // End color
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 45),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From Location Tile
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedFromLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        _showLocationDrawer('from');
                      },
                    ),
                    const Divider(),

                    // To Location Tile
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedToLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        setState(() {
                          _selectedBusId = null;
                        });
                        _showLocationDrawer('to');
                      },
                    ),
                    const Divider(),

                    // Date of Journey Picker
                    ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.black),
                      title: const Text(
                        'Date of Journey',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        _selectedDate != null
                            ? DateFormat('EEE d-MMM').format(_selectedDate!)
                            : 'Select a date',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedBusId = null;
                        });
                        _selectDate(context);
                      },
                    ),
                    const Divider(),

                    // Bottom Buttons for Today/Tomorrow
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = DateTime.now();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.grey.shade400,
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = DateTime.now()
                                      .add(const Duration(days: 1));
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.grey.shade400,
                              ),
                              child: const Text(
                                'Tomorrow',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Slot Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value:
                            _getAvailableTimings().contains(_selectedTimeSlot)
                                ? _selectedTimeSlot
                                : null,
                        hint: const Text('Choose a time slot'),
                        items: _getAvailableTimings().map((String slot) {
                          return DropdownMenuItem<String>(
                            value: slot,
                            child: Text(slot),
                          );
                        }).toList(),
                        onChanged: (_selectedFromLocation != 'From' &&
                                _selectedToLocation != 'To' &&
                                _selectedDate != null)
                            ? (String? newValue) {
                                setState(() {
                                  _selectedTimeSlot = newValue;
                                });
                              }
                            : null,
                        isExpanded: true,
                        menuMaxHeight: 250,
                      ),
                    ),
                    const Divider(),
                    // Bus selected
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedBusId ?? 'Select Bus',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _handleBusTileTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: const Color(0xFF17203A),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: const Color(0xFF17203A),
            color: Colors.white,
            rippleColor: const Color(0xFF17203A),
            haptic: true,
            tabBorderRadius: 30,
            tabActiveBorder: Border.all(color: const Color(0xFFF0F4FA), width: 1),
            tabBorder: Border.all(color: const Color(0xFF17203A), width: 1),
            tabShadow: [
              BoxShadow(
                  color: const Color(0xFF17203A).withOpacity(0.5), blurRadius: 8)
            ],
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 250),
            gap: 8,
            activeColor: Colors.white,
            iconSize: 30,
            tabBackgroundColor: const Color(0xFF4A5670),
            padding: const EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              GButton(
                icon: Icons.place,
                text: 'GPS',
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MapScreen()));
                  });
                },
              ),
              GButton(
                icon: Icons.help,
                text: 'help',
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HelplineScreen()));
                  });
                },
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
