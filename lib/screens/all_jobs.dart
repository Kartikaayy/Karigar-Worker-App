import 'package:flutter/material.dart';
import '../all temporary data/upcoming_details.dart';
import '../all temporary data/dummy_bookings.dart';

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

  late List<Map<String, dynamic>> allJobs;

  @override
  void initState() {
    super.initState();
    allJobs = [
      ...jobs,
      ...upcomingBookings.map((booking) => {
        'status': booking['status'] ?? 'Upcoming',
        'service': booking['service'],
        'description': booking['description'],
        'location': booking['location'],
        'time': booking['time'],
        'price': booking['price'] != null ? '₹${booking['price']}' : '₹0',
      }),
    ];
  }

  void _updateStatus(int index, String status) {
    setState(() {
      allJobs[index]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Upcoming', 'Completed', 'Accepted', 'Rejected']
                      .map((filter) {
                    bool isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = filteredJobs[index];
                  int realIndex = allJobs.indexOf(job);
                  return _buildJobCard(job, realIndex);
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

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    Color borderColor;
    Color statusColor;
    Color cardColor = Colors.white;

    String status = job['status'];

    if (status == 'Active') {
      borderColor = Colors.orange;
      statusColor = Colors.orange;
    } else if (status == 'Upcoming') {
      borderColor = Colors.blue;
      statusColor = Colors.blue;
    } else if (status == 'Completed') {
      borderColor = Colors.green;
      statusColor = Colors.green;
      cardColor = Colors.green.shade100;
    } else if (status == 'Accepted') {
      borderColor = Colors.green;
      statusColor = Colors.green;
      cardColor = Colors.green.shade100;
    } else if (status == 'Rejected') {
      borderColor = Colors.red;
      statusColor = Colors.red;
      cardColor = Colors.red.shade100;
    } else {
      borderColor = Colors.grey;
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
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
                  status,
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
          // View Details button conditionally rendered (Not shown for Completed jobs)
          if (status != 'Completed')
            ElevatedButton(
              onPressed: () async {
                String? result = await showModalBottomSheet<String>(
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
                      onAction: (status) => Navigator.pop(_, status),
                    );
                  },
                );
                if (result != null) {
                  _updateStatus(index, result);
                }
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () => onAction?.call('Accepted'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Accept"),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () => onAction?.call('Rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reject"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
