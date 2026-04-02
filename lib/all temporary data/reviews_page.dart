import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewsPage extends StatefulWidget {
  final String workerId;

  const ReviewsPage({super.key, required this.workerId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool hasError = false;
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

    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await http.get(
        Uri.parse('http://13.201.137.141:5000/api/reviews/worker/${widget.workerId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            reviews = List<Map<String, dynamic>>.from(data['data'].map((review) => {
              'user': review['customerId']?['name'] ?? 'Anonymous User',
              'rating': (review['rating'] ?? 0).toDouble(),
              'review': review['review'] ?? 'No review provided',
              'service': _getServiceName(review['workerServiceId']),
              'date': _formatDate(review['createdAt']),
              'avatar': _getAvatarEmoji(review['customerId']?['name']),
              'bookingId': review['bookingId'] ?? '',
            }));
            isLoading = false;
          });

          _animationController.forward();
        } else {
          setState(() {
            hasError = true;
            errorMessage = 'No reviews found for this worker';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to load reviews. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error loading reviews: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _getServiceName(dynamic workerServiceId) {
    // You can customize this based on your service categories
    // For now, returning a default value
    if (workerServiceId != null && workerServiceId is Map) {
      return workerServiceId['name'] ?? 'General Service';
    }
    return 'General Service';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _getAvatarEmoji(String? name) {
    if (name == null || name.isEmpty) return '👤';

    // Simple avatar generation based on first letter
    final firstLetter = name.toUpperCase()[0];
    const avatars = {
      'A': '👨‍💼', 'B': '👩‍💼', 'C': '👨‍🔧', 'D': '👩‍🏫', 'E': '👨‍🏗️',
      'F': '👩‍💻', 'G': '👨‍🎨', 'H': '👩‍🔬', 'I': '👨‍🍳', 'J': '👩‍⚕️',
      'K': '👨‍🎓', 'L': '👩‍🎤', 'M': '👨‍✈️', 'N': '👩‍🚀', 'O': '👨‍🚒',
      'P': '👩‍🌾', 'Q': '👨‍🏭', 'R': '👩‍💼', 'S': '👨‍🔧', 'T': '👩‍🏫',
      'U': '👨‍💻', 'V': '👩‍🎨', 'W': '👨‍🔬', 'X': '👩‍🍳', 'Y': '👨‍⚕️', 'Z': '👩‍🎓'
    };

    return avatars[firstLetter] ?? '👤';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get overallRating {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (sum, review) => sum + review['rating']);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }

  Map<int, int> get ratingDistribution {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      int rating = review['rating'].floor();
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }
    return distribution;
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Your Reviews',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _fetchReviews,
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
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
                          'Customer Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'See what your customers say about you',
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.reviews_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${reviews.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading reviews...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReviews,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7043).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: const Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Reviews Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some bookings to start receiving reviews from your customers.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Overall Rating Card
          _buildAnimatedCard(
            delay: 100,
            child: _buildOverallRatingCard(),
          ),

          const SizedBox(height: 24),

          // Rating Distribution
          _buildAnimatedCard(
            delay: 200,
            child: _buildRatingDistribution(),
          ),

          const SizedBox(height: 32),

          // Reviews Header
          Row(
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
                child: Icon(Icons.rate_review_rounded, color: const Color(0xFFFF7043), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Customer Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Reviews List
          ...reviews.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> review = entry.value;
            return _buildAnimatedCard(
              delay: 300 + (index * 100),
              child: _buildReviewTile(review),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final cardAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (delay / 1000).clamp(0.0, 1.0),
            ((delay + 300) / 1000).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ));

        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (delay / 1000).clamp(0.0, 1.0),
              ((delay + 300) / 1000).clamp(0.0, 1.0),
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

  Widget _buildOverallRatingCard() {
    return Material(
      elevation: 8,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.3),
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
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
                        "Overall Rating",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            overallRating.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "out of 5",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
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
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Total Reviews', '${reviews.length}'),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                  _buildStatItem('Satisfaction', '${(overallRating / 5 * 100).round()}%'),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                  _buildStatItem('5-Star Reviews', '${ratingDistribution[5]}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingDistribution() {
    return Material(
      elevation: 4,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.2),
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
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Rating Breakdown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              int stars = 5 - index;
              int count = ratingDistribution[stars] ?? 0;
              double percentage = reviews.isNotEmpty ? count / reviews.length : 0.0;
              return _buildRatingBar(stars, count, percentage);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: percentage,
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
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 3,
        shadowColor: const Color(0xFFFF7043).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              color: const Color(0xFFFF7043).withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF7043).withOpacity(0.1),
                          const Color(0xFFFF7043).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        review['avatar'] ?? '👤',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['user'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                review['service'] ?? 'Service',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review['date'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          review['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Review Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  review['review'] ?? 'No review text',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}