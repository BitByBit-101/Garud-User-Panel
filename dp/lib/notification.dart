import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Notifications',
          style: TextStyle(color: Color(0xFFF0F4FA)),
        ),
        backgroundColor: const Color(0xFF17203A), // Setting AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Change icon color here
      ),
      backgroundColor: Colors.white, // Setting background color to white
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .orderBy('date_time',
                descending: true) // Sort by time, latest first
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map Firestore data to notification list
          final notifications = snapshot.data!.docs;

          return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data =
                    notifications[index].data() as Map<String, dynamic>;

                // Extract data fields
                final busId = data['busId'] ?? 'Unknown Bus';
                final dateTime = (data['date_time'] as Timestamp).toDate();
                final message = data['message'] ?? 'No message';
                final type = data['type'] ?? 'general';

                // Determine color based on type
                Color getColorForType(String type) {
                  switch (type) {
                    case 'landslide':
                      return Colors.red.shade200;
                    case 'busdelay':
                      return Colors.orange.shade200;
                    case 'general':
                    default:
                      return const Color(0xFF17203A).withOpacity(0.2);
                  }
                }

                final formattedDate = DateFormat('d MMMM y').format(dateTime);
                return Card(
                  color: getColorForType(type),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: Colors.grey.shade600,
                        ),
                        Text(
                          busId,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                    title: Text(message,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Empty space for alignment
                          const SizedBox(),
                          // Display formatted date on the right
                          Text(
                            formattedDate,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle tap for detailed notification info
                    },
                  ),
                );
              });
        },
      ),
    );
  }
}
