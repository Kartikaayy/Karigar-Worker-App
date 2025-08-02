import 'package:flutter/material.dart';
import '../screens/profile_page.dart';
import '../screens/notification_page.dart';
import '../screens/earning_page.dart';
import 'upcoming_details.dart';
import '../screens/all_jobs.dart';
import '../utils/dummy_bookings.dart'; // <-- Import shared bookings list

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ActiveJobsPage(),
    const AllJobsPage(),
    const EarningPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7043),
        elevation: 2,
        automaticallyImplyLeading: false,
        title: const Text(
          "Karigar Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF7043).withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.work, 0),
              label: "Active",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.list_alt, 1),
              label: "All Jobs",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.bar_chart, 2),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 3),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }
}

// ----------- ACTIVE JOBS PAGE WITH UPCOMING BOOKINGS (Electrician Only) ---------------
class ActiveJobsPage extends StatelessWidget {
  const ActiveJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFF3E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome Back,",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Karigar!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "Upcoming Bookings (Electrician)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Upcoming Electrician Bookings List from dummy_bookings.dart
          ...upcomingBookings.map((booking) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['service'] ?? '',
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Customer: ${booking['customer'] ?? ''}"),
                  Text("Date & Time: ${booking['time'] ?? ''}"),
                  Text("Address: ${booking['location'] ?? ''}"),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) {
                            return UpcomingDetailsSheet(
                              service: booking['service'] ?? '',
                              customer: booking['customer'] ?? '',
                              time: booking['time'] ?? '',
                              location: booking['location'] ?? '',
                              description: booking['description'] ?? '',
                              price: booking['price'] ?? '',
                            );
                          },
                        );
                      },
                      child: const Text("View Details"),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
