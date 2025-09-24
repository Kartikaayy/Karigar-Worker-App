import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> with TickerProviderStateMixin {
  String selectedFilter = 'All';
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  late AnimationController _refreshController;
  late AnimationController _scrollAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scrollFadeAnimation;

  // Add ScrollController for header management
  late ScrollController _scrollController;
  bool _showCompactHeader = false;

  List<Map<String, dynamic>> allJobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scrollAnimationController, curve: Curves.easeInOut),
    );

    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fetchBookings();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_showCompactHeader) {
      setState(() {
        _showCompactHeader = true;
      });
      _scrollAnimationController.forward();
    } else if (_scrollController.offset <= 50 && _showCompactHeader) {
      setState(() {
        _showCompactHeader = false;
      });
      _scrollAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterAnimationController.dispose();
    _refreshController.dispose();
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('https://callkaargarapi.rahulsh.me/api/bookings/worker'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bookingsData = jsonResponse['data'] as List? ?? [];

        setState(() {
          allJobs = bookingsData.map<Map<String, dynamic>>((booking) {
            return {
              '_id': booking['_id'] ?? '',
              'status': _mapApiStatusToUI(booking['status'] ?? 'pending'),
              'service': booking['workerServiceId']?['description'] ?? 'Unknown Service',
              'description': booking['description'] ?? 'No description provided',
              'location': _formatAddress(booking['address_id']),
              'time': _formatBookingDate(booking['bookingDate']),
              'price': (booking['totalAmount'] ?? '0').toString(),
              'customerName': booking['customerId']?['name'] ?? 'Unknown Customer',
              'customerPhone': booking['customerId']?['phone'] ?? '',
              'rawData': booking,
            };
          }).toList();
          _isLoading = false;
        });
        _animationController.forward();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load bookings: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _mapApiStatusToUI(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
        return 'Upcoming';
      case 'accepted':
      case 'confirmed':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'rejected':
      case 'cancelled':
        return 'Rejected';
      default:
        return 'Upcoming';
    }
  }

  String _formatAddress(dynamic addressData) {
    if (addressData == null) return 'Location not specified';

    final addressLine = (addressData['addressLine'] ?? '') as String;
    final city = (addressData['city'] ?? '') as String;
    final state = (addressData['state'] ?? '') as String;

    List<String> parts = [addressLine, city, state]
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Location not specified';
  }

  String _formatBookingDate(dynamic bookingDate) {
    if (bookingDate == null) return 'Date not specified';

    try {
      final date = DateTime.parse(bookingDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        } else {
          return '${difference.inHours} hours ago';
        }
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return bookingDate.toString();
    }
  }

  Future<void> _refreshBookings() async {
    _refreshController.repeat();
    await _fetchBookings();
    _refreshController.stop();
  }

  void _updateStatus(int index, String status) {
    setState(() {
      allJobs[index]['status'] = status;
    });
  }

  void _updateFilter(String filter) {
    _filterAnimationController.reset();
    setState(() {
      selectedFilter = filter;
    });
    _filterAnimationController.forward();
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
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
    final filteredJobs = selectedFilter == 'All'
        ? allJobs
        : allJobs.where((job) => job['status'] == selectedFilter).toList();

    return Scaffold(
      body: Container(
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
              // Simplified Header
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showCompactHeader ? 70 : 100,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, _showCompactHeader ? 8 : 16),
                  child: _showCompactHeader ? _buildCompactHeader() : _buildFullHeader(),
                ),
              ),

              // Main Content
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
                          : _buildContentWithFilter(filteredJobs),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return FadeTransition(
      opacity: _scrollFadeAnimation,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'All Jobs',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _refreshBookings,
              icon: RotationTransition(
                turns: _refreshController,
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.work_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'All Jobs',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your service requests',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
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
            'Loading your bookings...',
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
              'Failed to Load Jobs',
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
              label: const Text('Retry'),
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

  Widget _buildContentWithFilter(List<Map<String, dynamic>> filteredJobs) {
    return Column(
      children: [
        // Sticky Filter Section
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filter Jobs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredJobs.length} jobs',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF7043),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Upcoming', 'Completed', 'Rejected']
                      .map((filter) => _buildFilterChip(filter)).toList(),
                ),
              ),
            ],
          ),
        ),

        // Jobs List
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState()
              : FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
                int realIndex = allJobs.indexOf(job);
                return _buildEnhancedJobCard(job, realIndex, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter) {
    bool isSelected = selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => _updateFilter(filter),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
              )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFFFF7043).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
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
                Icons.work_off_rounded,
                size: 64,
                color: const Color(0xFFFF7043).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${selectedFilter == 'All' ? '' : selectedFilter} Jobs',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'All'
                  ? 'Your jobs will appear here once you start receiving requests'
                  : 'No jobs found for the selected filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedJobCard(Map<String, dynamic> job, int realIndex, int displayIndex) {
    Color primaryColor;
    Color backgroundColor;
    IconData statusIcon;
    String status = job['status'];

    switch (status) {
      case 'Active':
        primaryColor = Colors.orange.shade600;
        backgroundColor = Colors.orange.shade50;
        statusIcon = Icons.play_circle_filled_rounded;
        break;
      case 'Upcoming':
        primaryColor = Colors.blue.shade600;
        backgroundColor = Colors.blue.shade50;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'Completed':
      case 'Accepted':
        primaryColor = Colors.green.shade600;
        backgroundColor = Colors.green.shade50;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
        primaryColor = Colors.red.shade600;
        backgroundColor = Colors.red.shade50;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        primaryColor = Colors.grey.shade600;
        backgroundColor = Colors.grey.shade50;
        statusIcon = Icons.help_outline_rounded;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (displayIndex * 0.1).clamp(0.0, 1.0),
            ((displayIndex * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: Container(
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
                      // Enhanced Header Row
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
                              status,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF7043),
                                  Color(0xFFFF8A65),
                                ],
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
                              '₹${job['price']}',
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
                            colors: [
                              Colors.blue.shade50,
                              Colors.white,
                            ],
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
                                    job['customerName'] ?? 'Unknown Customer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  if (job['customerPhone'] != null && job['customerPhone'].isNotEmpty)
                                    Text(
                                      job['customerPhone'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (job['customerPhone'] != null && job['customerPhone'].isNotEmpty)
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
                        job['service'],
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
                          job['description'],
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

                      // Location and Time with Enhanced Design
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
                                          job['location'],
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
                                          job['time'],
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

                      // Enhanced Action Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: status == 'Upcoming'
                                ? LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade500])
                                : status == 'Active'
                                ? LinearGradient(colors: [Colors.orange.shade600, Colors.orange.shade500])
                                : LinearGradient(colors: [const Color(0xFFFF7043), const Color(0xFFFF8A65)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (status == 'Upcoming' ? Colors.blue.shade600 :
                                status == 'Active' ? Colors.orange.shade600 :
                                const Color(0xFFFF7043)).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _showJobDetails(job, realIndex),
                            icon: Icon(
                              status == 'Upcoming' ? Icons.visibility_rounded :
                              status == 'Active' ? Icons.play_circle_filled_rounded :
                              Icons.visibility_rounded,
                              size: 20,
                            ),
                            label: Text(
                              status == 'Upcoming' ? 'Review & Accept' :
                              status == 'Active' ? 'Mark Complete' :
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
          ),
        );
      },
    );
  }

  Future<void> _showJobDetails(Map<String, dynamic> job, int index) async {
    String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildEnhancedBottomSheet(job, index),
    );
    if (result != null && result != 'Completed' && result != 'Rejected') {
      final bookingId = job['_id'];
      if (bookingId.isNotEmpty) {
        await _updateBookingStatus(bookingId, result);
      } else {
        _updateStatus(index, result);
      }
    }
  }

  Widget _buildEnhancedBottomSheet(Map<String, dynamic> job, int index) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.work_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['service'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Booking Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₹${job['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details Section with Enhanced Cards
                  _buildDetailCard(Icons.person_rounded, 'Customer', job['customerName'] ?? 'N/A', Colors.blue),
                  _buildDetailCard(Icons.phone_rounded, 'Phone', job['customerPhone'] ?? 'N/A', Colors.green),
                  _buildDetailCard(Icons.schedule_rounded, 'Time', job['time'], Colors.purple),
                  _buildDetailCard(Icons.location_on_rounded, 'Location', job['location'], Colors.orange),
                  _buildDetailCard(Icons.description_rounded, 'Description', job['description'], Colors.indigo),

                  const SizedBox(height: 32),

                  // Enhanced Action Buttons
                  if (job['status'] == 'Upcoming')
                    Column(
                      children: [
                        Row(
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
                                  onPressed: () => Navigator.pop(context, 'rejected'),
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('Reject'),
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
                      ],
                    )
                  else if (job['status'] == 'Active')
                    SizedBox(
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
                    )
                  else
                    SizedBox(
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
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value, MaterialColor colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.shade200),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorScheme.shade500, colorScheme.shade400]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
}