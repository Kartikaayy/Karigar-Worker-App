import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart'; // Ensure this path is correct
import '../widgets/profile_image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Initialize with hardcoded data and placeholders
  Map<String, String> profileData = {
    "name": "Kallu Mistri",
    "phone": "5647382910",
    "email": "mistri@gmail.com",
    "gender": "Male",
    "profession": "Plumber",
    "experience": "+5 years",
    "area": "Bhopal",
    "street": "123 Main St",
    "city": "Bhopal",
    "state": "Madhya Pradesh",
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load cached data first for quick display
    _fetchProfileFromAPI(); // Then fetch the latest data from the server
  }

  Future<void> _fetchProfileFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      _handleApiError({'error': 'no_token', 'message': 'No token found.'});
      setState(() { _isLoading = false; });
      return;
    }

    // Step 1: Fetch basic user profile
    final Map<String, dynamic> apiResponse = await ApiService.getUserProfile(token);

    if (apiResponse['error'] != null) {
      _handleApiError(apiResponse);
    } else {
      _updateProfileState(apiResponse);
      _saveProfileData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Merges API data with hardcoded defaults.
  void _updateProfileState(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        profileData["name"] = data["name"] ?? profileData["name"];
        profileData["phone"] = data["phone"] ?? profileData["phone"];
        profileData["email"] = data["email"] ?? profileData["email"];
        // For other fields, they'll remain hardcoded as the API response doesn't contain them
      });
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Load data from SharedPreferences; if not found, use the hardcoded defaults.
        profileData["name"] = prefs.getString('name') ?? profileData["name"]!;
        profileData["phone"] = prefs.getString('phone') ?? profileData["phone"]!;
        profileData["email"] = prefs.getString('email') ?? profileData["email"]!;
        profileData["gender"] = prefs.getString('gender') ?? profileData["gender"]!;
        profileData["profession"] = prefs.getString('profession') ?? profileData["profession"]!;
        profileData["experience"] = prefs.getString('experience') ?? profileData["experience"]!;
        profileData["area"] = prefs.getString('area') ?? profileData["area"]!;
        profileData["street"] = prefs.getString('street') ?? profileData["street"]!;
        profileData["city"] = prefs.getString('city') ?? profileData["city"]!;
        profileData["state"] = prefs.getString('state') ?? profileData["state"]!;
      });
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', profileData["name"]!);
    prefs.setString('phone', profileData["phone"]!);
    prefs.setString('email', profileData["email"]!);
    prefs.setString('gender', profileData["gender"]!);
    prefs.setString('profession', profileData["profession"]!);
    prefs.setString('experience', profileData["experience"]!);
    prefs.setString('area', profileData["area"]!);
    prefs.setString('street', profileData["street"]!);
    prefs.setString('city', profileData["city"]!);
    prefs.setString('state', profileData["state"]!);
  }

  void _handleApiError(Map<String, dynamic> error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${error['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (error['error'] == 'unauthorized' && mounted) {
      // Logic to navigate to LoginScreen
    }
  }

  Future<void> _editField(String field, String currentValue) async {
    TextEditingController controller = TextEditingController(text: currentValue);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter new $field",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );

    if (newText != null && newText.isNotEmpty && newText != currentValue) {
      setState(() {
        profileData[field] = newText;
      });
      _saveProfileData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$field updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const ProfileImagePicker(),
            const SizedBox(height: 10),
            Text(
              profileData["name"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              profileData["profession"]!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _infoCard(
              title: "Personal Information",
              details: {
                "Name": profileData["name"]!,
                "Phone": profileData["phone"]!,
                "Email": profileData["email"]!,
                "Gender": profileData["gender"]!,
              },
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: "Professional Details",
              details: {
                "Profession": profileData["profession"]!,
                "Experience": profileData["experience"]!,
                "Working Area": profileData["area"]!,
              },
            ),
            const SizedBox(height: 16),
            _documentCard(),
            const SizedBox(height: 16),
            _infoCard(
              title: "Address Information",
              details: {
                "Street": profileData["street"]!,
                "City": profileData["city"]!,
                "State": profileData["state"]!,
              },
            ),
            const SizedBox(height: 16),
            _accountSettingsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required Map<String, String> details,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.orange.shade100, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(thickness: 1, color: Colors.black12, height: 20),
          ...details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _editField(entry.key, entry.value),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _documentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.orange.shade100, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Documents & Verification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(thickness: 1, color: Colors.black12, height: 20),
          _documentRow("Aadhaar Card", true),
          _documentRow("Photo", true),
          _documentRow("PAN Card", true),
        ],
      ),
    );
  }

  Widget _documentRow(String docName, bool isApproved) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(docName, style: const TextStyle(color: Colors.grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isApproved ? "Approved" : "Pending",
            style: TextStyle(
              color: isApproved ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.orange.shade100, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Account Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(thickness: 1, color: Colors.black12, height: 20),
          _settingsRow("Notification Settings", "Enabled"),
          const SizedBox(height: 10),
          _settingsRow("Privacy & Security", "Standard"),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Do you really want to logout?'),
                    actions: [
                      TextButton(
                        child: const Text('No'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Yes', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // You need to import this screen
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => const LoginScreen()),
                          //       (Route<dynamic> route) => false,
                          // );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(String setting, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(setting, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}