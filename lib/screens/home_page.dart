import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../verification/document_verification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ActiveJobsPage(),
    const AllJobsPage(),
    const EarningsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Karigar Dashboard",
        showBack: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.work, 0),
              label: "Active",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.list_alt, 1),
              label: "All Jobs",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.bar_chart, 2),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 3),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
    );
  }
}

// ----------- VISUAL UPGRADED ACTIVE PAGE ---------------
class ActiveJobsPage extends StatelessWidget {
  const ActiveJobsPage({super.key});

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
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/avatar.png'), // Use a valid asset or network image
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Welcome Back,", style: TextStyle(fontSize: 16)),
                  Text(
                    "Karigar!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.verified_user, size: 32, color: Colors.orange),
              title: const Text("Document Verification",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Upload your documents to get verified."),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentVerificationPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade100),
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange.shade50.withOpacity(0.3),
            ),
            child: const Text(
              "Tip: Keep your documents ready to increase trust and get more job offers!",
              style: TextStyle(color: Colors.deepOrange, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- OTHER TABS ----------
class AllJobsPage extends StatelessWidget {
  const AllJobsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("All Jobs Page"));
  }
}

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Earnings Page"));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profile Page"));
  }
}
