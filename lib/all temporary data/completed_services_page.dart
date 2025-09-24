import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CompletedServicesPage extends StatefulWidget {
  const CompletedServicesPage({super.key});

  @override
  State<CompletedServicesPage> createState() => _CompletedServicesPageState();
}

class _CompletedServicesPageState extends State<CompletedServicesPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchWorkerPayments();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _headerSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkerPayments() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      // Haptic feedback for better UX
      HapticFeedback.lightImpact();

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      print('Fetching from: https://callkaargarapi.rahulsh.me/api/payments/worker');
      print('Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('https://callkaargarapi.rahulsh.me/api/payments/worker'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different possible response structures
        List<Map<String, dynamic>> parsedServices = [];

        if (data is List) {
          parsedServices = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          parsedServices = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data.containsKey('payments')) {
          parsedServices = List<Map<String, dynamic>>.from(data['payments']);
        } else if (data is Map) {
          parsedServices = [Map<String, dynamic>.from(data)];
        }

        setState(() {
          services = parsedServices.map((service) {
            // Updated logic to safely access nested data
            final bookingData = service['bookingId'] as Map<String, dynamic>?;
            final customerData = service['customerId'] as Map<String, dynamic>?;

            return {
              'service': bookingData?['serviceName'] ?? 'Unknown Service',
              'date': service['createdAt'] ?? 'Date not available',
              'amount': (service['amount'] ?? 0).toString(),
              'status': bookingData?['status'] ?? 'pending',
              'customer': customerData?['name'] ?? 'Unknown Customer',
              'id': service['_id'],
            };
          }).toList();
          isLoading = false;
        });
        _animationController.forward();
        _cardAnimationController.forward();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load payments: HTTP ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString().replaceAll('Exception: ', '');
        services = []; // Set services to an empty list on error
      });
      _animationController.forward();
      _cardAnimationController.forward();
      HapticFeedback.mediumImpact();
    }
  }

  double getTotalEarnings() {
    double total = 0;
    for (var service in services) {
      String amountStr = service["amount"]?.toString() ?? '0';
      amountStr = amountStr.replaceAll(RegExp(r'[\₹,]'), '');
      total += double.tryParse(amountStr) ?? 0;
    }
    return total;
  }

  IconData _getServiceIcon(String serviceName) {
    serviceName = serviceName.toLowerCase();
    if (serviceName.contains('paint')) return Icons.format_paint_outlined;
    if (serviceName.contains('electric') || serviceName.contains('wiring')) return Icons.electrical_services_outlined;
    if (serviceName.contains('ac') || serviceName.contains('air')) return Icons.ac_unit_outlined;
    if (serviceName.contains('fan')) return Icons.toys_outlined;
    if (serviceName.contains('led') || serviceName.contains('light') || serviceName.contains('panel')) return Icons.lightbulb_outlined;
    if (serviceName.contains('geyser') || serviceName.contains('water')) return Icons.water_drop_outlined;
    if (serviceName.contains('chimney') || serviceName.contains('kitchen')) return Icons.kitchen_outlined;
    return Icons.handyman_outlined;
  }

  List<Color> _getServiceGradient(int index) {
    final gradients = [
      [const Color(0xFF6B73FF), const Color(0xFF9B59B6)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      [const Color(0xFFFC466B), const Color(0xFF3F5EFB)],
      [const Color(0xFFFFCE00), const Color(0xFFFE4880)],
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    ];
    return gradients[index % gradients.length];
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    switch (status) {
      case 'completed':
        return const Color(0xFF00C851);
      case 'confirmed':
        return const Color(0xFF2196F3);
      case 'pending':
        return const Color(0xFFFF8F00);
      case 'cancelled':
        return const Color(0xFFFF3D00);
      default:
        return const Color(0xFF757575);
    }
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final status = service["status"]?.toString() ?? 'pending';
    final gradient = _getServiceGradient(index);
    final amount = service["amount"]?.toString() ?? '0';
    final amountNum = double.tryParse(amount.replaceAll(RegExp(r'[\₹,]'), '')) ?? 0;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
          child: Transform.scale(
            scale: 0.95 + (0.05 * _fadeAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  top: index == 0 ? 8 : 0,
                  left: 4,
                  right: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => HapticFeedback.selectionClick(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: gradient[0].withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradient[0].withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getServiceIcon(service["service"] ?? ''),
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service["service"] ?? 'Unknown Service',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (service["customer"] != null) ...[
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF3498DB).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                Icons.person_outline_rounded,
                                                size: 16,
                                                color: const Color(0xFF3498DB),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              service["customer"],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF5D6D7E),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF95A5A6).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: Color(0xFF95A5A6),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            service["date"] ?? 'Date not available',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF7F8C8D),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    gradient[0].withOpacity(0.08),
                                    gradient[1].withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: gradient[0].withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EARNING',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7F8C8D),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${amountNum.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: gradient[0],
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getStatusColor(status).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7043).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Fetching your payments...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please wait a moment',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade400.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Connection Failed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Failed to load data',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7043).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _fetchWorkerPayments,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = getTotalEarnings();
    final completedCount = services.where((s) => s['status']?.toString().toLowerCase() == 'completed').length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFBF7),
              Color(0xFFFFF8F3),
              Color(0xFFFFF4EC),
              Color(0xFFFFE6D3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Animated Header
            SafeArea(
              child: AnimatedBuilder(
                animation: _headerSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _headerSlideAnimation.value),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.pop(context);
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 20,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Completed Services",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2C3E50),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFF7043).withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'TOTAL SERVICES',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7F8C8D),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${services.length}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFF7043),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF00C851).withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'COMPLETED',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7F8C8D),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$completedCount',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF00C851),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await _fetchWorkerPayments();
                },
                color: const Color(0xFFFF7043),
                backgroundColor: Colors.white,
                strokeWidth: 3,
                child: isLoading
                    ? Center(child: _buildLoadingState())
                    : hasError && services.isEmpty
                    ? Center(child: _buildErrorState())
                    : services.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 80,
                        color: Color(0xFFBDC3C7),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'No Services Yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your completed services will appear here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    // Remove the hardcoded error banner since demo data is gone
                    if (hasError) // This check still works if you want to show a general error state
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Services List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return _buildServiceCard(services[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Enhanced Total Earnings Footer
            Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF7043),
                    Color(0xFFFF5722),
                    Color(0xFFE64A19),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7043).withOpacity(0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF7043).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Earnings",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$completedCount completed • ${services.length} total",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "₹${totalEarnings.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (totalEarnings > 0 && services.isNotEmpty)
                              Text(
                                "avg ₹${(totalEarnings / services.length).toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}