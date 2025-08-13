import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Widget buildNotificationTile({
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFFFCCBC),
            child: Icon(Icons.notifications, color: Colors.deepOrange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    )),
                const SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 6),
                Text(time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // match ActiveJobsPage bg
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7043),
        elevation: 2,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          buildNotificationTile(
            title: "New Job Request",
            message: "You have a new job request for AC Installation.",
            time: "Just now",
          ),
          buildNotificationTile(
            title: "Job Payment Received",
            message: "₹3,800 payment received for Painting Service.",
            time: "2 hours ago",
          ),
          buildNotificationTile(
            title: "Profile Verified",
            message: "Your documents have been successfully verified.",
            time: "Yesterday",
          ),
        ],
      ),
    );
  }
}
