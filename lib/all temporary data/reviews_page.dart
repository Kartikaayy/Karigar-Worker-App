import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  final List<Map<String, dynamic>> reviews = const [
    {
      'user': 'Rahul Sharma',
      'rating': 5.0,
      'review': 'Excellent service! Very professional and punctual.',
    },
    {
      'user': 'Anjali Mehra',
      'rating': 4.5,
      'review': 'Great work on the AC installation. Recommended!',
    },
    {
      'user': 'Suresh Verma',
      'rating': 4.0,
      'review': 'Good service, but arrived slightly late.',
    },
    {
      'user': 'Pooja Singh',
      'rating': 5.0,
      'review': 'Amazing work! Fixed my wiring issues quickly.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    double overallRating = 4.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reviews'),
        backgroundColor: const Color(0xFFFF7043),
      ),
      body: Container(
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
            // Overall Rating Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Rating",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        overallRating.toString(),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text("(${reviews.length} reviews)",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: overallRating / 5.0,
                    color: Colors.amber,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text("All Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            ...reviews.map((review) => _buildReviewTile(review)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade50,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/avatar.png'), // Dummy avatar
              ),
              const SizedBox(width: 10),
              Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(review['rating'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review['review'], style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.shade100,
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
