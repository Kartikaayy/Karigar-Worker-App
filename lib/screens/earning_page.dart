import 'package:flutter/material.dart';

class EarningPage extends StatelessWidget {  // <-- Rename here
  const EarningPage({super.key});

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
          const Text(
            "Earnings Summary",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Total Earnings Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Earnings", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text(
                  "₹12,460",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text("Last payout: ₹3,800 • 2 days ago",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Service Rating Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Service Rating", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 6),
                    Text("4.8", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Text("(98 reviews)", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.9,
                  color: Colors.amber,
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text("Recent Payouts", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Recent Payouts List
          _buildPayoutTile("Painting Service", "2 days ago", "₹3,800"),
          _buildPayoutTile("Electrical Wiring", "5 days ago", "₹1,200"),
          _buildPayoutTile("AC Installation", "Last week", "₹2,500"),
        ],
      ),
    );
  }

  // Card style
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

  // Payout tile builder
  Widget _buildPayoutTile(String service, String timeAgo, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(timeAgo, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
