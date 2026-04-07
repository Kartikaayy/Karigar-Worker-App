import 'package:flutter/material.dart';
import 'api/api.dart'; // ← single import for all API classes
import 'package:shared_preferences/shared_preferences.dart';
import 'package:call_karigar_worker_application/all temporary data/completed_services_page.dart';
import 'package:call_karigar_worker_application/all temporary data/reviews_page.dart';

class EarningPage extends StatefulWidget {
  final String workerId; // Add workerId parameter

  const EarningPage({super.key, required this.workerId});

  @override
  State<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends State<EarningPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // New state variables for dynamic data
  double totalEarnings = 0.0;
  double lastPayoutAmount = 0.0;
  String lastPayoutDate = 'N/A';
  double rating = 0.0;
  int reviewsCount = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fetchEarningsData(); // Call the new method to fetch data
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchEarningsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      // ── UPDATED: uses PaymentsApi & ReviewsApi ───────────────────────
      final earningsData = await PaymentsApi.getWorkerEarnings(token);
      final reviewsData  = await ReviewsApi.getWorkerReviews(
          token: token, workerId: widget.workerId);
      // ─────────────────────────────────────────────────────────────────

      if (earningsData != null) {
        final List<dynamic> payments = earningsData['data'] ?? [];

        double total = 0;
        double lastAmount = 0;
        String lastDate = 'N/A';

        if (payments.isNotEmpty) {
          // Calculate total earnings
          for (var payment in payments) {
            final amount = payment['amount'] ?? 0;
            total += amount.toDouble();
          }

          // Get last payout details
          final latestPayment = payments.first;
          lastAmount = (latestPayment['amount'] ?? 0).toDouble();
          lastDate = latestPayment['createdAt'] ?? 'N/A';
        }

        setState(() {
          totalEarnings = total;
          lastPayoutAmount = lastAmount;
          lastPayoutDate = lastDate;
        });
      } else {
        throw Exception('Failed to load earnings data.');
      }

      if (reviewsData != null) {
        final List<dynamic> reviews = reviewsData['data'] ?? [];

        double totalRating = 0;
        for (var review in reviews) {
          totalRating += (review['rating'] ?? 0).toDouble();
        }

        setState(() {
          reviewsCount = reviews.length;
          if (reviews.isNotEmpty) {
            rating = totalRating / reviewsCount;
          } else {
            rating = 0.0;
          }
        });
      } else {
        throw Exception('Failed to load reviews data.');
      }

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Earnings Summary',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track your financial progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
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
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator(color: Color(0xFFFF7043)))
                            : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            // Total Earnings Card
                            _buildAnimatedCard(
                              delay: 200,
                              child: _buildTotalEarningsCard(),
                            ),

                            const SizedBox(height: 24),

                            // Service Rating Card
                            _buildAnimatedCard(
                              delay: 300,
                              child: _buildServiceRatingCard(),
                            ),

                            const SizedBox(height: 32),

                            // // Recent Payouts Section (You can fetch this dynamically too)
                            // _buildAnimatedCard(
                            //   delay: 400,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Row(
                            //         children: [
                            //           Container(
                            //             padding: const EdgeInsets.all(8),
                            //             decoration: BoxDecoration(
                            //               gradient: LinearGradient(
                            //                 colors: [
                            //                   const Color(0xFFFF7043).withOpacity(0.1),
                            //                   const Color(0xFFFF7043).withOpacity(0.05),
                            //                 ],
                            //               ),
                            //               borderRadius: BorderRadius.circular(8),
                            //             ),
                            //             child: Icon(
                            //               Icons.history_rounded,
                            //               color: const Color(0xFFFF7043),
                            //               size: 20,
                            //             ),
                            //           ),
                            //           const SizedBox(width: 12),
                            //           const Text(
                            //             "Recent Payouts",
                            //             style: TextStyle(
                            //               fontSize: 18,
                            //               fontWeight: FontWeight.bold,
                            //               color: Color(0xFF2C3E50),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       const SizedBox(height: 20),
                            //       _buildEnhancedPayoutTile("Painting Service", "2 days ago", "₹3,800", Icons.format_paint_rounded),
                            //       _buildEnhancedPayoutTile("Electrical Wiring", "5 days ago", "₹1,200", Icons.electrical_services_rounded),
                            //       _buildEnhancedPayoutTile("AC Installation", "Last week", "₹2,500", Icons.ac_unit_rounded),
                            //     ],
                            //   ),
                           // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Material(
      elevation: 8,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.3),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CompletedServicesPage()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF7043),
                const Color(0xFFFF8A65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+12%', // This can also be made dynamic
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Total Earnings",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "₹${totalEarnings.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Last payout: ₹${lastPayoutAmount.toStringAsFixed(0)} • ${lastPayoutDate.length > 10 ? lastPayoutDate.substring(0, 10) : lastPayoutDate}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Tap to view completed services",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRatingCard() {
    return Material(
      elevation: 6,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewsPage(workerId: widget.workerId), // Pass workerId here
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFFF7043).withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.amber.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Your Service Rating",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Color(0xFFFF7043), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "View Reviews",
                          style: TextStyle(
                            color: const Color(0xFFFF7043),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$reviewsCount reviews",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: (rating / 5.0).clamp(0.0, 1.0),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final cardAnimation = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (delay / 1000).clamp(0.0, 1.0),
            ((delay + 200) / 1000).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ));

        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (delay / 1000).clamp(0.0, 1.0),
              ((delay + 200) / 1000).clamp(0.0, 1.0),
            ),
          ),
        );

        return SlideTransition(
          position: cardAnimation,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPayoutTile(String service, String timeAgo, String amount, IconData serviceIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        shadowColor: const Color(0xFFFF7043).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFFF7043).withOpacity(0.01),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFFF7043).withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF7043).withOpacity(0.1),
                      const Color(0xFFFF7043).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  serviceIcon,
                  color: const Color(0xFFFF7043),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 16),
                    Text(
                      amount.replaceAll('₹', ''),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}