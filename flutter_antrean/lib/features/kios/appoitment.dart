import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late DatabaseReference _appointmentsRef;
  late String _userId;
  bool _isLoading = true;
  String _nomorAntrean = ""; // Variable to store "nomor" value
  String _status = "menunggu"; // Default status

  @override
  void initState() {
    super.initState();
    
    // Get the logged-in user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;  // Assign the UID of the logged-in user
    } else {
      _userId = '';
    }

    // Getting the reference to the appointment data in Firebase based on user ID
    _appointmentsRef = FirebaseDatabase.instance.ref('antrean/POLI_GIGI/$_userId');

    // Fetch the appointment data based on the UID
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      // Fetch appointment data from Firebase based on UID
      final snapshot = await _appointmentsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;

        // Only fetch the "nomor" and "status" fields for the logged-in user
        setState(() {
          _nomorAntrean = data['nomor'] ?? "No appointment found"; // Default if no data found
          _status = data['status'] ?? "No status available"; // Default status if not available
        });
      } else {
        setState(() {
          _nomorAntrean = "No appointment found.";
          _status = "No status available";
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading false after fetching data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // UI for showing the appointment number and status
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Antrian $_nomorAntrean', // Display the appointment number
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Anda masuk dalam antrian, mohon menunggu', // Status message
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Cancel appointment logic can be added here
                            print("Cancel pressed for $_nomorAntrean");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
