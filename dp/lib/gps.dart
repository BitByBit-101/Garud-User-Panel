//  working code
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      lerpDouble(begin!.latitude, end!.latitude, t)!,
      lerpDouble(begin!.longitude, end!.longitude, t)!,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  // final DatabaseReference _locationRef =
  //     FirebaseDatabase.instance.ref('busLocations/busA');
  final DatabaseReference _busLocationsRef =
      FirebaseDatabase.instance.ref('busLocations');
  LatLng _busLocation =
      const LatLng(28.9905081, 76.9873477); // Default location
  Set<Marker> _markers = {}; // Set to hold markers
  late BitmapDescriptor _customIcon;
  late AnimationController _animationController;
  late Animation<LatLng> _animation;
  List<Map<String, dynamic>> checkpoints = [];
  double speed = 0.0;
  List<String> availableBuses = []; // List of bus IDs
  String? selectedBus; // Currently selected bus ID
  bool isLoadingBuses = true;
  // Set<Polyline> _polylines = {};
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _loadCustomMarker();
    _initializeAnimation();
    // _subscribeToLocationUpdates();
    _fetchCheckpoints();
    _fetchAvailableBuses();
  }

  Future<void> _fetchAvailableBuses() async {
    try {
      final snapshot = await _busLocationsRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic>? data =
            snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            availableBuses = data.keys.cast<String>().toList();
          });
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Error fetching available buses: $e');
    } finally {
      setState(() {
        isLoadingBuses = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: 'Failed to cancel the ticket.\n$error',
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _fetchCheckpoints() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('Checkpoints').get();
    // Iterate through the checkpoint documents and create markers
    snapshot.docs.forEach((doc) async {
      final checkpointName = doc['checkpoint_name'] ?? 'Unknown';
      final checkpointDetails = doc['checkpoint_details'];
      final lat = checkpointDetails['latitude'] ?? 0.0;
      final lng = checkpointDetails['longitude'] ?? 0.0;
      final checkpointFullName =
          checkpointDetails['checkpoint_full_name'] ?? 'Unknown';

      LatLng checkpointLocation = LatLng(lat, lng);
      checkpoints.add({
        'checkpoint_name': checkpointName,
        'location': checkpointLocation,
        'full_name': checkpointFullName,
      });
    });
  }

  Future<void> _updateBusMarkerWithTravelTimes() async {
    if (checkpoints.isEmpty) {
      await _fetchCheckpoints(); // Ensure checkpoints are fetched if not already done
    }

    // Get the current bus location
    LatLng busLocation = _busLocation;

    String travelTimesText = "";

    // Calculate travel time to each checkpoint
    for (var checkpoint in checkpoints) {
      LatLng checkpointLocation = checkpoint['location'];
      // String checkpointName = checkpoint['checkpoint_name'];
      String checkpointFullName = checkpoint['full_name'];
      // Fetch travel time using Google Distance Matrix API
      double distance = Geolocator.distanceBetween(
        busLocation.latitude,
        busLocation.longitude,
        checkpointLocation.latitude,
        checkpointLocation.longitude,
      );
      double timeToCheckpoint =
          (speed > 0) ? (distance / (speed / 3.6)) : double.infinity;
      double timeToCheckpointInMinutes = timeToCheckpoint / 60;
      if (timeToCheckpoint != double.infinity) {
        travelTimesText +=
            '$checkpointFullName: ${timeToCheckpointInMinutes.toStringAsFixed(1)} min\n';
      } else {
        travelTimesText += '$checkpointFullName: Bus is stationary\n';
      }
    }

    // Update the bus marker with the travel times
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('busLocation'),
          position: _busLocation,
          infoWindow: InfoWindow(
            title: 'Checkpoints',
            snippet: travelTimesText,
          ),
          icon: _customIcon,
        ),
      };
    });
  }

  Future<void> _loadCustomMarker() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // Adjust size as needed
      'images/bus_icon.png',
    );
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Handle Firebase initialization error
      _showErrorDialog(context, 'Error initializing Firebase: $e');
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(
          milliseconds: 300), // Adjust duration for smoother movement
      vsync: this,
    );
  }

  void _subscribeToLocationUpdates(String busId) {
    _busLocationsRef.child(busId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        print(data);
        final lat = data['latitude'] as double?;
        final lng = data['longitude'] as double?;
        final newSpeed = data['speed'] as double?;
        if (lat != null && lng != null) {
          final newLocation = LatLng(lat, lng);
          speed = newSpeed ?? speed;
          _animateMarkerMovement(newLocation);
        }
      }
    });
  }

  void _animateMarkerMovement(LatLng newLocation) {
    final oldLocation = _busLocation;
    final distance = Geolocator.distanceBetween(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    if (distance < 0.01) {
      // Directly update the marker if movement is too slight for animation
      setState(() {
        _busLocation = newLocation;
        // _markers = {
        //   Marker(
        //     markerId: const MarkerId('busLocation'),
        //     position: _busLocation,
        //     infoWindow: const InfoWindow(
        //       title: 'Bus Location',
        //       snippet:
        //           'Travel times to checkpoints: ${()}',
        //     ),
        //     icon: _customIcon,
        //   ),
        // };
        _updateBusMarkerWithTravelTimes();
      });
    } else {
      // Animate the marker for noticeable distance changes
      _animation = LatLngTween(begin: oldLocation, end: newLocation).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      )..addListener(() {
          setState(() {
            _busLocation = _animation.value;
            _updateBusMarkerWithTravelTimes();
            // _markers = {
            //   Marker(
            //     markerId: const MarkerId('busLocation'),
            //     position: _busLocation,
            //     infoWindow: const InfoWindow(title: 'Bus Location'),
            //     icon: _customIcon,
            //   ),
            // };
          });
          _updateMapCenter(_animation.value);
        });

      // Start animation from the beginning
      _animationController.forward(from: 0);
    }
  }

  void _updateMapCenter(LatLng newCenter) {
    mapController.animateCamera(CameraUpdate.newLatLng(newCenter));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // You can add initial markers here if necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracking Map'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Dropdown to select bus
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoadingBuses
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedBus,
                    hint: const Text('Select a Bus'),
                    items: availableBuses.map((bus) {
                      return DropdownMenuItem(
                        value: bus,
                        child: Text(bus),
                      );
                    }).toList(),
                    onChanged: (String? newBusId) {
                      setState(() {
                        selectedBus = newBusId;
                      });
                      if (newBusId != null) {
                        _subscribeToLocationUpdates(newBusId);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _busLocation,
                zoom: 14.0,
              ),
              markers: _markers, // Pass the markers set to the map
            ),
          ),
        ],
      ),
    );
  }
}























// //  working code 

// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class LatLngTween extends Tween<LatLng> {
//   LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);

//   @override
//   LatLng lerp(double t) {
//     return LatLng(
//       lerpDouble(begin!.latitude, end!.latitude, t)!,
//       lerpDouble(begin!.longitude, end!.longitude, t)!,
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen>
//     with SingleTickerProviderStateMixin {
//   late GoogleMapController mapController;
//   final DatabaseReference _locationRef =
//       FirebaseDatabase.instance.ref('busLocations/busA');
//   LatLng _busLocation =
//       const LatLng(28.9905081, 76.9873477); // Default location
//   Set<Marker> _markers = {}; // Set to hold markers
//   late BitmapDescriptor _customIcon;
//   late AnimationController _animationController;
//   late Animation<LatLng> _animation;
//   @override
//   void initState() {
//     super.initState();
//     _initializeFirebase();
//     _loadCustomMarker();
//     _initializeAnimation();
//     _subscribeToLocationUpdates();
//     _fetchCheckpoints();
//   }

//   Future<Map<String, dynamic>?> _fetchRouteData(
//       LatLng origin, LatLng destination) async {
//     final apiKey = dotenv.env['GOOGLE_API_KEY']; // Get the API key from .env

//     // Construct the URL for the Directions API request
//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/directions/json'
//       '?origin=${origin.latitude},${origin.longitude}'
//       '&destination=${destination.latitude},${destination.longitude}'
//       '&key=$apiKey',
//     );

//     try {
//       // Send the HTTP GET request
//       final response = await http.get(url);

//       // Check if the response is successful
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status'] == 'OK') {
//           final route = data['routes'][0];
//           final leg = route['legs'][0];

//           final distance = leg['distance']['value']; // Distance in meters
//           final duration = leg['duration']['value']; // Duration in seconds

//           return {
//             'distance': distance,
//             'duration': duration,
//           };
//         } else {
//           print('Error in Directions API response: ${data['status']}');
//         }
//       } else {
//         print('Error fetching directions: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching route data: $e');
//     }

//     return null;
//   }

//   Future<void> _fetchCheckpoints() async {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     QuerySnapshot snapshot = await firestore.collection('Checkpoints').get();

//     // Iterate through the checkpoint documents and create markers
//     snapshot.docs.forEach((doc) {
//       final checkpointName = doc['checkpoint_name'] ?? 'Unknown';
//       final checkpointDetails = doc['checkpoint_details'];
//       final lat = checkpointDetails['latitude'] ?? 0.0;
//       final lng = checkpointDetails['longitude'] ?? 0.0;
//       final checkpointFullName =
//           checkpointDetails['checkpoint_full_name'] ?? 'Unknown';

//       LatLng checkpointLocation = LatLng(lat, lng);

//       setState(() {
//         _markers.add(
//           Marker(
//             markerId: MarkerId(checkpointName),
//             position: checkpointLocation,
//             infoWindow: InfoWindow(
//               title: checkpointFullName,
//               snippet: 'Timing: 10:30 AM', // Replace with actual timing logic
//             ),
//             icon: _customIcon,
//           ),
//         );
//       });
//     });
//   }

//   Future<void> _loadCustomMarker() async {
//     _customIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)), // Adjust size as needed
//       'images/bus_icon.png',
//     );
//   }

//   Future<void> _initializeFirebase() async {
//     try {
//       await Firebase.initializeApp();
//     } catch (e) {
//       // Handle Firebase initialization error
//       print('Error initializing Firebase: $e');
//     }
//   }

//   void _initializeAnimation() {
//     _animationController = AnimationController(
//       duration: const Duration(
//           milliseconds: 300), // Adjust duration for smoother movement
//       vsync: this,
//     );
//   }

//   void _subscribeToLocationUpdates() {
//     _locationRef.onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         print(data);
//         final lat = data['latitude'] as double?;
//         final lng = data['longitude'] as double?;
//         if (lat != null && lng != null) {
//           final newLocation = LatLng(lat, lng);
//           _animateMarkerMovement(newLocation);
//         }
//       }
//     });
//   }

//   void _animateMarkerMovement(LatLng newLocation) {
//     final oldLocation = _busLocation;
//     final distance = Geolocator.distanceBetween(
//       oldLocation.latitude,
//       oldLocation.longitude,
//       newLocation.latitude,
//       newLocation.longitude,
//     );

//     if (distance < 1.0) {
//       // Directly update the marker if movement is too slight for animation
//       setState(() {
//         _busLocation = newLocation;
//         _markers = {
//           Marker(
//             markerId: const MarkerId('busLocation'),
//             position: _busLocation,
//             infoWindow: const InfoWindow(title: 'Bus Location'),
//             icon: _customIcon,
//           ),
//         };
//       });
//     } else {
//       // Animate the marker for noticeable distance changes
//       _animation = LatLngTween(begin: oldLocation, end: newLocation).animate(
//         CurvedAnimation(
//           parent: _animationController,
//           curve: Curves.easeInOut,
//         ),
//       )..addListener(() {
//           setState(() {
//             _busLocation = _animation.value;
//             _markers = {
//               Marker(
//                 markerId: const MarkerId('busLocation'),
//                 position: _busLocation,
//                 infoWindow: const InfoWindow(title: 'Bus Location'),
//                 icon: _customIcon,
//               ),
//             };
//           });
//           _updateMapCenter(_animation.value);
//         });

//       // Start animation from the beginning
//       _animationController.forward(from: 0);
//     }
//   }

//   void _updateMapCenter(LatLng newCenter) {
//     mapController.animateCamera(CameraUpdate.newLatLng(newCenter));
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     // You can add initial markers here if necessary
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('GPS Tracking Map'),
//         elevation: 2,
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _busLocation,
//           zoom: 14.0,
//         ),
//         markers: _markers, // Pass the markers set to the map
//       ),
//     );
//   }
// }

  // Future<Map<String, dynamic>?> _fetchRouteData(
  //     LatLng origin, LatLng destination) async {
  //   // Construct the URL for the Directions API request
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/distancematrix/json'
  //     '?origins=${origin.latitude},${origin.longitude}'
  //     '&destinations=${destination.latitude},${destination.longitude}'
  //     '&departure_time=now'
  //     '&traffic_model=best_guess'
  //     '&key=$apiKey',
  //   );

  //   try {
  //     // Send the HTTP GET request
  //     final response = await http.get(url);

  //     // Check if the response is successful
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       if (data['status'] == 'OK') {
  //         final element = data['rows'][0]['elements'][0];

  //         final duration = element['duration_in_traffic']
  //             ['value']; // Duration considering traffic in seconds

  //         return {
  //           'duration': duration,
  //         };
  //       } else {
  //         print('Error in Distance Matrix API response: ${data['status']}');
  //       }
  //     } else {
  //       print('Error fetching route data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching route data: $e');
  //   }

  //   return null;
  // }