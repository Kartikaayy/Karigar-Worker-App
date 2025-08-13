import 'package:flutter/material.dart';

class CompletedServicesPage extends StatelessWidget {
  const CompletedServicesPage({super.key});

  final List<Map<String, String>> services = const [
    {"service": "Painting Service", "date": "2 days ago", "amount": "₹3,800"},
    {"service": "Electrical Wiring", "date": "5 days ago", "amount": "₹1,200"},
    {"service": "AC Installation", "date": "Last week", "amount": "₹2,500"},
    {"service": "Fan Repair", "date": "10 days ago", "amount": "₹960"},
    {"service": "LED Fitting", "date": "2 weeks ago", "amount": "₹1,500"},
    {"service": "Geyser Service", "date": "3 weeks ago", "amount": "₹2,500"},
  ];

  int getTotalEarnings() {
    int total = 0;
    for (var service in services) {
      String amountStr = service["amount"]!.replaceAll(RegExp(r'[\₹,]'), '');
      total += int.parse(amountStr);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = getTotalEarnings();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const Text(
                      "Completed Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,

                      ),
                    ),

                    const SizedBox(width: 24), // Placeholder for symmetry
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service["service"]!,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(service["date"]!,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(service["amount"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Total Earnings Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7043),
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Earnings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "₹$totalEarnings",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
