import 'package:flutter/material.dart';
import '../all temporary data/upcoming_details.dart';
import '../all temporary data/dummy_bookings.dart'; // <-- Import shared upcoming bookings

class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> jobs = [
    {
      'status': 'Active',
      'service': 'Electrical Wiring',
      'description': 'New power outlet installation',
      'location': 'Gwalior, MP',
      'time': '1 hour ago',
      'price': '₹1200',
    },
    {
      'status': 'Completed',
      'service': 'Fan Repair',
      'description': 'Ceiling fan motor replacement',
      'location': 'Ujjain, MP',
      'time': 'Completed Yesterday',
      'price': '₹700',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Combine Active Jobs, Upcoming Bookings, and Completed Jobs
    final allJobs = [
      ...jobs,
      ...upcomingBookings.map((booking) => {
        'status': 'Upcoming',
        'service': booking['service'],
        'description': booking['description'],
        'location': booking['location'],
        'time': booking['time'],
        'price': '₹${booking['price']}',
      }),
    ];

    final filteredJobs = selectedFilter == 'All'
        ? allJobs
        : allJobs.where((job) => job['status'] == selectedFilter).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFF3E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Like Text (No Orange BG)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'All Jobs',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Count Boxes Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCountBox('8', 'Active', Colors.orange.shade100, Colors.orange),
                  const SizedBox(width: 6),
                  _buildCountBox('${upcomingBookings.length}', 'Upcoming', Colors.blue.shade100, Colors.blue),
                  const SizedBox(width: 6),
                  _buildCountBox('25', 'Completed', Colors.green.shade100, Colors.green),
                ],
              ),
            ),

            // Filter Tabs Row
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['All', 'Active', 'Upcoming', 'Completed'].map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF7043) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Jobs List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = filteredJobs[index];
                  return _buildJobCard(job, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBox(String count, String label, Color bgColor, Color textColor) {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: textColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, BuildContext context) {
    Color borderColor;
    Color statusColor;
    if (job['status'] == 'Active') {
      borderColor = Colors.orange;
      statusColor = Colors.orange;
    } else if (job['status'] == 'Upcoming') {
      borderColor = Colors.blue;
      statusColor = Colors.blue;
    } else {
      borderColor = Colors.green;
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job['service'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                job['price'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(job['description']),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(job['location']),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(job['time']),
            ],
          ),
          const SizedBox(height: 10),

          // Conditional Buttons
          job['status'] == 'Completed'
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
          )
              : ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) {
                  return UpcomingDetailsSheet(
                    service: job['service'],
                    customer: 'Customer Name',
                    time: job['time'],
                    location: job['location'],
                    description: job['description'],
                    price: job['price'],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}
