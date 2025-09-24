// Enhanced ActiveJobsPage with improved UI and status colors
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../screens/categories_page.dart';
import '../screens/profile_page.dart';
import '../screens/notification_page.dart';
import '../screens/earning_page.dart';
import '../all temporary data/upcoming_details.dart';
import '../screens/all_jobs.dart';
import '../screens/add_service_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  String? _workerId;

  // Initialize pages list as empty, will be populated after workerId is loaded
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _loadWorkerId();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkerId() async {
    final prefs = await SharedPreferences.getInstance();
    final workerId = prefs.getString("workerId");
    print("Worker ID retrieved in HomePage: $workerId");

    setState(() {
      _workerId = workerId;
      // Initialize pages after workerId is loaded
      _pages = [
        const ActiveJobsPage(),
        const AllJobsPage(),
        EarningPage(workerId: workerId ?? ''), // Pass workerId to EarningPage if needed
        ProfilePage(), // Pass workerId to ProfilePage
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if workerId is not loaded yet
    if (_workerId == null || _pages.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "Karigar Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (_workerId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoriesPage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('Worker ID is not loaded yet. Please wait.')),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7043).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _fabAnimationController.reset();
              _fabAnimationController.forward();
            },
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.work_rounded, 0),
                label: "Active",
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.list_alt_rounded, 1),
                label: "All Jobs",
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.bar_chart_rounded, 2),
                label: "Earnings",
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_rounded, 3),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white60,
        size: isSelected ? 26 : 24,
      ),
    );
  }
}

// Enhanced ActiveJobsPage with improved UI and status colors
class ActiveJobsPage extends StatefulWidget {
  const ActiveJobsPage({super.key});

  @override
  State<ActiveJobsPage> createState() => _ActiveJobsPageState();
}

class _ActiveJobsPageState extends State<ActiveJobsPage> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _bookings = [];
  late AnimationController _animationController;
  late AnimationController _refreshController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String? _errorMessage;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // Enhanced status mapping similar to AllJobsPage
  String _mapApiStatusToUI(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
      case 'confirmed':
        return 'Confirmed';
      case 'in-progress':
      case 'active':
        return 'in-progress';
      case 'completed':
        return 'Completed';
      case 'rejected':
      case 'cancelled':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  // Enhanced color mapping based on status
  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'primaryColor': Colors.orange.shade600,
          'backgroundColor': Colors.orange.shade50,
          'statusIcon': Icons.schedule_rounded,
          'gradient': [Colors.orange.shade600, Colors.orange.shade500],
        };
      case 'confirmed':
        return {
          'primaryColor': Colors.blue.shade600,
          'backgroundColor': Colors.blue.shade50,
          'statusIcon': Icons.check_circle_outline_rounded,
          'gradient': [Colors.blue.shade600, Colors.blue.shade500],
        };
      case 'in-progress':
        return {
          'primaryColor': Colors.purple.shade600,
          'backgroundColor': Colors.purple.shade50,
          'statusIcon': Icons.work_outline_rounded,
          'gradient': [Colors.purple.shade600, Colors.purple.shade500],
        };
      case 'completed':
        return {
          'primaryColor': Colors.green.shade600,
          'backgroundColor': Colors.green.shade50,
          'statusIcon': Icons.check_circle_rounded,
          'gradient': [Colors.green.shade600, Colors.green.shade500],
        };
      case 'rejected':
        return {
          'primaryColor': Colors.red.shade600,
          'backgroundColor': Colors.red.shade50,
          'statusIcon': Icons.cancel_rounded,
          'gradient': [Colors.red.shade600, Colors.red.shade500],
        };
      default:
        return {
          'primaryColor': Colors.grey.shade600,
          'backgroundColor': Colors.grey.shade50,
          'statusIcon': Icons.help_outline_rounded,
          'gradient': [Colors.grey.shade600, Colors.grey.shade500],
        };
    }
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final workerId = prefs.getString('workerId');
      final token = prefs.getString('token');

      if (workerId == null || token == null) {
        throw Exception('Worker ID or token not found');
      }

      final response = await http.get(
        Uri.parse('https://callkaargarapi.rahulsh.me/api/bookings/worker'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bookingsData = jsonResponse['data'] as List? ?? [];

        setState(() {
          _bookings = bookingsData.map<Map<String, dynamic>>((booking) {
            return {
              '_id': booking['_id'] ?? '',
              'status': _mapApiStatusToUI(booking['status'] ?? 'pending'),
              'rawStatus': booking['status'] ?? 'pending',
              'service': booking['workerServiceId']?['description'] ?? 'Unknown Service',
              'description': booking['description'] ?? 'No description provided',
              'location': _formatAddress(booking['address_id']),
              'time': _formatBookingDate(booking['bookingDate']),
              'price': (booking['totalAmount'] ?? '0').toString(),
              'customerName': booking['customerId']?['name'] ?? 'Unknown Customer',
              'customerPhone': booking['customerId']?['phone'] ?? '',
              'bookingDate': booking['bookingDate'],
              'address_id': booking['address_id'],
              'workerServiceId': booking['workerServiceId'],
              'customerId': booking['customerId'],
            };
          }).toList();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatAddress(dynamic addressData) {
    if (addressData == null) return 'Location not specified';

    final addressLine = (addressData['addressLine'] ?? '') as String;
    final city = (addressData['city'] ?? '') as String;

    List<String> parts = [addressLine, city].where((part) => part.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Location not specified';
  }

  String _formatBookingDate(dynamic bookingDate) {
    if (bookingDate == null) return 'Date not specified';

    try {
      final date = DateTime.parse(bookingDate);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return bookingDate.toString();
    }
  }

  Future<void> _refreshBookings() async {
    _refreshController.repeat();
    await _fetchBookings();
    _refreshController.stop();
  }

  void _showBookingDetails(Map<String, dynamic> booking) async {
    final serviceName = booking['service'] ?? 'No service name';
    final customerName = booking['customerName'] ?? 'N/A';
    final description = booking['description'] ?? 'No description provided.';
    final price = booking['price'] ?? 'N/A';
    final formattedDate = booking['time'] ?? 'N/A';
    final addressText = booking['location'] ?? 'N/A';

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnhancedBottomSheet(
        booking,
        serviceName,
        customerName,
        formattedDate,
        addressText,
        description,
        price,
      ),
    );

    if (result != null) {
      if (result == 'accepted') {
        _updateStatus(booking['_id']!, 'accepted');
      } else if (result == 'rejected') {
        _updateStatus(booking['_id']!, 'rejected');
      }
      else{
        _updateStatus(booking['_id']!, 'completed');
      }
    }
  }

  Widget _buildEnhancedBottomSheet(
      Map<String, dynamic> booking,
      String service,
      String customer,
      String time,
      String location,
      String description,
      String price,
      ) {
    final statusStyle = _getStatusStyle(booking['status']);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Enhanced Header with Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: statusStyle['gradient']),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusStyle['primaryColor'].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(statusStyle['statusIcon'], color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹$price',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Section
            _buildDetailRow(Icons.person_rounded, 'Customer', customer, Colors.blue),
            _buildDetailRow(Icons.schedule_rounded, 'Date & Time', time, Colors.purple),
            _buildDetailRow(Icons.location_on_rounded, 'Address', location, Colors.orange),
            _buildDetailRow(Icons.description_rounded, 'Description', description, Colors.indigo),

            const SizedBox(height: 32),

            // Dynamic Action Buttons based on status
            _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    String status = booking['status'].toLowerCase();

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade600, Colors.red.shade500]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool? confirm = await _showRejectDialog();
                  if (confirm == true) {
                    Navigator.pop(context, 'rejected');
                  }
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade500]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, 'accepted'),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade500]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade600.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'completed'),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'in-progress') {
      return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade500]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade600.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'complete'),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Mark as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade500]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, MaterialColor colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorScheme.shade500, colorScheme.shade400]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRejectDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_rounded, color: Colors.red.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Reject Booking'),
            ],
          ),
          content: const Text('Are you sure you want to reject this booking? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      String apiEndpoint;
      String requestBody = '';
      String successMessage = '';

      // Map the UI status to appropriate API endpoint and request body
      switch (newStatus.toLowerCase()) {
        case 'accepted':
        case 'active':
          apiEndpoint = 'https://callkaargarapi.rahulsh.me/api/bookings/$bookingId/handle-request';
          requestBody = jsonEncode({'action': 'accept'});
          successMessage = 'Booking accepted successfully';
          break;
        case 'rejected':
        case 'cancelled':
          apiEndpoint = 'https://callkaargarapi.rahulsh.me/api/bookings/$bookingId/handle-request';
          requestBody = jsonEncode({'action': 'reject'});
          successMessage = 'Booking rejected successfully';
          break;
        case 'completed':
          apiEndpoint = 'https://callkaargarapi.rahulsh.me/api/bookings/$bookingId/complete';
          requestBody = '{}'; // Empty JSON object for complete endpoint
          successMessage = 'Booking marked as completed';
          break;
        default:
          throw Exception('Unsupported status: $newStatus');
      }

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Update Status Response: ${response.statusCode}');
      print('Update Status Body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchBookings(); // Refresh the data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to update booking status');
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF7043),
            Color(0xFFFFAB91),
            Color(0xFFFFF3E0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back,",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              "Karigar!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _refreshBookings,
                          icon: RotationTransition(
                            turns: _refreshController,
                            child: const Icon(Icons.refresh_rounded, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFF8F5), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: _isLoading
                        ? _buildLoadingState()
                        : _errorMessage != null
                        ? _buildErrorState()
                        : _buildContentState(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading bookings...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchBookings,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF7043).withOpacity(0.1),
                        const Color(0xFFFF7043).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.schedule_rounded, color: const Color(0xFFFF7043), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Active Bookings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_bookings.length}',
                    style: const TextStyle(
                      color: Color(0xFFFF7043),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: _bookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ));

                    return SlideTransition(
                      position: slideAnimation,
                      child: AnimatedOpacity(
                        opacity: booking['isRemoving'] == true ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildEnhancedBookingCard(booking, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          //   // View All Button
          //   Padding(
          //     padding: const EdgeInsets.all(24),
          //     child: Container(
          //       width: double.infinity,
          //       height: 56,
          //       decoration: BoxDecoration(
          //         gradient: const LinearGradient(
          //           colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
          //         ),
          //         borderRadius: BorderRadius.circular(28),
          //         boxShadow: [
          //           BoxShadow(
          //             color: const Color(0xFFFF7043).withOpacity(0.3),
          //             blurRadius: 12,
          //             offset: const Offset(0, 6),
          //           ),
          //         ],
          //       ),
          //       child: ElevatedButton.icon(
          //         onPressed: () {
          //           final homeState = context.findAncestorStateOfType<_HomePageState>();
          //           if (homeState != null) {
          //             homeState.setState(() {
          //               homeState._currentIndex = 1;
          //             });
          //           }
          //         },
          //         icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
          //         label: const Text(
          //           "View All Bookings",
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.transparent,
          //           shadowColor: Colors.transparent,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(28),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7043).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 64,
                color: const Color(0xFFFF7043).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your active bookings will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBookingCard(Map<String, dynamic> booking, int index) {
    final statusStyle = _getStatusStyle(booking['status']);
    final primaryColor = statusStyle['primaryColor'];
    final backgroundColor = statusStyle['backgroundColor'];
    final statusIcon = statusStyle['statusIcon'];

    final bool isConfirmed = booking['status'].toLowerCase() == 'confirmed';

    void _showQrCodeDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/main_qr.png', // Path to your QR code image
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Booking ID: ${booking['_id']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 6,
        shadowColor: primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.white, backgroundColor.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header Row with Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(statusIcon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isConfirmed)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            _showQrCodeDialog(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.qr_code_rounded, color: Colors.blue.shade600, size: 20),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7043).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${booking['price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Customer Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['customerName'] ?? 'Unknown Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            if (booking['customerPhone'] != null && booking['customerPhone'].isNotEmpty)
                              Text(
                                booking['customerPhone'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (booking['customerPhone'] != null && booking['customerPhone'].isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_rounded,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Service Title
                Text(
                  booking['service'],
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    booking['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 16),

                // Location and Time
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade50, Colors.orange.shade100],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.orange.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    booking['location'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.purple.shade100],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.purple.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.purple.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    booking['time'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Dynamic Action Button based on status
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: statusStyle['gradient']),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showBookingDetails(booking),
                      icon: Icon(
                        booking['status'].toLowerCase() == 'pending' ? Icons.visibility_rounded :
                        booking['status'].toLowerCase() == 'confirmed' ? Icons.play_circle_filled_rounded :
                        booking['status'].toLowerCase() == 'in-progress' ? Icons.check_circle_rounded :
                        Icons.visibility_rounded,
                        size: 20,
                      ),
                      label: Text(
                        booking['status'].toLowerCase() == 'pending' ? 'Review & Accept' :
                        booking['status'].toLowerCase() == 'confirmed' ? 'Mark Completed' :
                        booking['status'].toLowerCase() == 'in-progress' ? 'Mark Complete' :
                        'View Details',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}