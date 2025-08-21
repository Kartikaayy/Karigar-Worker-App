import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this for SharedPreferences
import '../screens/profile_page.dart';
import '../screens/notification_page.dart';
import '../screens/earning_page.dart';
import '../all temporary data/upcoming_details.dart';
import '../screens/all_jobs.dart';
import '../all temporary data/dummy_bookings.dart';
import '../screens/add_service_page.dart';

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

  String? _workerId;

  @override
  void initState() {
    super.initState();
    _loadWorkerId();
  }

  // Asynchronous method to load the worker ID
  Future<void> _loadWorkerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workerId = prefs.getString("workerId");
      print("Worker ID retrieved in HomePage: $_workerId");
    });
  }

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
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // Check if the worker ID is loaded before navigating
              if (_workerId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddServicePage(workerId: _workerId!),
                  ),
                );
              } else {
                // Show a message if the ID is not available yet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Worker ID is not loaded yet. Please wait.'),
                  ),
                );
              }
            },
            tooltip: 'Add a new service',
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

class ActiveJobsPage extends StatefulWidget {
  const ActiveJobsPage({super.key});

  @override
  State<ActiveJobsPage> createState() => _ActiveJobsPageState();
}

class _ActiveJobsPageState extends State<ActiveJobsPage> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> bookings;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    bookings = List.from(upcomingBookings);
    bookings.insert(0, {
      'service': 'New Fan Installation',
      'customer': 'Amit Sharma',
      'time': 'Tomorrow, 11 AM',
      'location': 'Sector 15, Noida',
      'description': 'Install a new ceiling fan',
      'price': '₹1,200',
      'isNew': true,
      'status': 'pending',
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateStatus(int index, String status) {
    if (status == 'rejected') {
      setState(() {
        bookings[index]['isRemoving'] = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          bookings.removeAt(index);
        });
      });
    } else {
      setState(() {
        bookings[index]['status'] = status;
      });
    }
  }

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

          ...bookings.asMap().entries.map((entry) {
            int index = entry.key;
            var booking = entry.value;

            Animation<double> animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index == 0 ? 0.0 : 1.0,
                index == 0 ? 1.0 : 1.0,
                curve: Curves.easeOut,
              ),
            );

            Color cardColor = booking['status'] == 'accepted'
                ? Colors.green.shade100
                : booking['status'] == 'rejected'
                ? Colors.red.shade100
                : (booking['isNew'] == true ? Colors.orange.shade50 : Colors.white);

            Color statusBadgeColor = booking['status'] == 'accepted'
                ? Colors.green
                : booking['status'] == 'rejected'
                ? Colors.red
                : Colors.grey;

            String? statusText = booking['status'] != 'pending' ? booking['status'].toString().toUpperCase() : null;

            return SizeTransition(
              sizeFactor: index == 0 ? animation : AlwaysStoppedAnimation(1.0),
              axisAlignment: -1.0,
              child: AnimatedOpacity(
                opacity: booking['isRemoving'] == true ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                              onPressed: () async {
                                String? result = await showModalBottomSheet<String>(
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
                                      onAction: (status) => Navigator.pop(context, status),
                                    );
                                  },
                                );

                                if (result != null) {
                                  _updateStatus(index, result);
                                }
                              },
                              child: const Text("View Details"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (statusText != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBadgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class UpcomingDetailsSheet extends StatelessWidget {
  final String service;
  final String customer;
  final String time;
  final String location;
  final String description;
  final String price;
  final Function(String)? onAction;

  const UpcomingDetailsSheet({
    super.key,
    required this.service,
    required this.customer,
    required this.time,
    required this.location,
    required this.description,
    required this.price,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Customer: $customer"),
          Text("Date & Time: $time"),
          Text("Address: $location"),
          const SizedBox(height: 10),
          Text("Description: $description"),
          Text("Price: $price"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'accepted');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Accept"),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Reject Booking'),
                        content: const Text('Are you sure you want to reject this booking?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Reject'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    Navigator.pop(context, 'rejected');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ],
          )
        ],
      ),
    );
  }
}