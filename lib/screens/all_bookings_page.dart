// lib/screens/all_bookings_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AllBookingsPage extends StatefulWidget {
  const AllBookingsPage({super.key});

  @override
  State<AllBookingsPage> createState() => _AllBookingsPageState();
}

class _AllBookingsPageState extends State<AllBookingsPage> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchBookings();
  }

  Future<List<dynamic>> _fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final workerId = prefs.getString('workerId');
    final token = prefs.getString('token'); // Assuming you store the token

    if (workerId == null || token == null) {
      throw Exception('Worker ID or token not found');
    }

    final response = await http.get(
      Uri.parse('https://call-kaarigar-server.onrender.com/api/bookings/worker'),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Worker-Id': workerId,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF7043),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No bookings found.'));
            } else {
              final bookings = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  // The API response structure might differ from your dummy data.
                  // Adjust the keys ('service', 'customer', etc.) as needed based on the actual API response.
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['service']?['serviceName'] ?? 'No service name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Customer: ${booking['customerName'] ?? 'N/A'}"),
                          Text("Date & Time: ${booking['bookingDate'] ?? 'N/A'}, ${booking['bookingTime'] ?? 'N/A'}"),
                          Text("Address: ${booking['customerAddress'] ?? 'N/A'}"),
                          const SizedBox(height: 8),
                          Text(
                            "Status: ${booking['status']?.toString().toUpperCase() ?? 'N/A'}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: booking['status'] == 'accepted'
                                  ? Colors.green
                                  : booking['status'] == 'rejected'
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}