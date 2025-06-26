import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class UserTicketsPage extends StatelessWidget {
  const UserTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text('Error: No logged-in user found'),
            ),
          );
        }

        final user = snapshot.data!;
        final userId = user.uid;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF191D32),
                      Color.fromARGB(255, 64, 72, 93),
                    ],
                  ),
                ),
              ),
              title: const Text(
                'Your Tickets',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white, // Changed arrow icon color to white
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 209, 215, 223),
                  Color.fromARGB(255, 209, 215, 223)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: UserTicketsPageContent(userId: userId),
          ),
        );
      },
    );
  }
}

class UserTicketsPageContent extends StatefulWidget {
  final String userId;

  const UserTicketsPageContent({super.key, required this.userId});

  @override
  _UserTicketsPageContentState createState() => _UserTicketsPageContentState();
}

class _UserTicketsPageContentState extends State<UserTicketsPageContent> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  List<Map<String, dynamic>> _tickets = [];

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchUserTickets();
  }

  Future<List<Map<String, dynamic>>> fetchUserTickets() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserBookings')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> bookedSeats = userDoc['bookedSeats'];
        return bookedSeats.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _showErrorDialog(context, "Error fetching tickets");
      return [];
    }
  }

  Future<void> cancelTicket(Map<String, dynamic> ticket) async {
    try {
      final bookingsCollectionRef =
          FirebaseFirestore.instance.collection('Bookings');

      final querySnapshot = await bookingsCollectionRef
          .where('busId', isEqualTo: ticket['busId'])
          .where('route', isEqualTo: ticket['route'])
          .where('date', isEqualTo: ticket['date'])
          .where('timing', isEqualTo: ticket['timing'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> bookedSeats =
              Map<String, dynamic>.from(doc['bookedSeats']);

          if (bookedSeats.containsKey(ticket['seatNo'].toString())) {
            bookedSeats.remove(ticket['seatNo'].toString());

            await doc.reference.update({'bookedSeats': bookedSeats});

            final userDocRef = FirebaseFirestore.instance
                .collection('UserBookings')
                .doc(widget.userId);
            DocumentSnapshot userDoc = await userDocRef.get();

            if (userDoc.exists && userDoc.data() != null) {
              List<dynamic> bookedSeatsList = List.from(userDoc['bookedSeats']);
              bookedSeatsList.removeWhere((seat) =>
                  seat['busId'] == ticket['busId'] &&
                  seat['seatNo'] == ticket['seatNo'] &&
                  seat['route'] == ticket['route'] &&
                  seat['date'] == ticket['date'] &&
                  seat['timing'] == ticket['timing']);

              await userDocRef.update({'bookedSeats': bookedSeatsList});

              setState(() {
                _tickets.remove(ticket);
              });

              _showSuccessDialog(context);
              return;
            }
          }
        }
      } else {
        _showErrorDialog(context, "No matching ticket found");
      }
    } catch (e) {
      _showErrorDialog(context, "Error cancelling ticket");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Ticket Cancelled',
      desc: 'Your ticket has been successfully cancelled.',
      btnOkOnPress: () {},
    ).show();
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

  void _showCancelBottomSheet(
      BuildContext context, Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancel Ticket',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Are you sure you want to cancel this ticket?',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                Navigator.pop(context);
                cancelTicket(ticket);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, int index) {
    final qrCodeBase64 = ticket['qrCodeBase64'];
    final qrBytes = qrCodeBase64 != null ? base64Decode(qrCodeBase64) : null;

    return GestureDetector(
      onTap: () {
        _showCancelBottomSheet(context, ticket);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2C6CBC),
              Color(0xFF71C3F7),
              Color(0xFFF6F6F6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus ID: ${ticket['busId']}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Seat No: ${ticket['seatNo']}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Route: ${ticket['route']}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Date: ${ticket['date']}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Timing: ${ticket['timing']}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (qrBytes != null)
                Image.memory(
                  qrBytes,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Error loading tickets'),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No tickets found'),
          );
        }

        _tickets = snapshot.data!;
        return ListView.builder(
          itemCount: _tickets.length,
          itemBuilder: (context, index) {
            return _buildTicketCard(_tickets[index], index);
          },
        );
      },
    );
  }
}
