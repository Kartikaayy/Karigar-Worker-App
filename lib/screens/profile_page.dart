// Your existing imports remain unchanged
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../widgets/profile_image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Rajesh Kumar";
  String phone = "+91 98765 43210";
  String email = "rajesh@email.com";
  String gender = "Male";
  String profession = "Electrician";
  String experience = "5+ years";
  String area = "Shivaji Nagar, Jabalpur";
  String street = "124, Street Name";
  String city = "Jabalpur";
  String stateName = "Madhya Pradesh";

  String? aadhaarFile = "aadhaar_demo.pdf";  // Simulating pre-uploaded file
  String? photoFile = "photo_demo.jpg";      // Simulating pre-uploaded file
  String? panFile = "pan_demo.pdf";          // Simulating pre-uploaded file

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? name;
      phone = prefs.getString('phone') ?? phone;
      email = prefs.getString('email') ?? email;
      gender = prefs.getString('gender') ?? gender;
      profession = prefs.getString('profession') ?? profession;
      experience = prefs.getString('experience') ?? experience;
      area = prefs.getString('area') ?? area;
      street = prefs.getString('street') ?? street;
      city = prefs.getString('city') ?? city;
      stateName = prefs.getString('stateName') ?? stateName;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('phone', phone);
    prefs.setString('email', email);
    prefs.setString('gender', gender);
    prefs.setString('profession', profession);
    prefs.setString('experience', experience);
    prefs.setString('area', area);
    prefs.setString('street', street);
    prefs.setString('city', city);
    prefs.setString('stateName', stateName);
  }

  void _editField(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                _saveProfileData();  // Save after update
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const ProfileImagePicker(),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              profession,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _infoCard(
              title: "Personal Information",
              details: {
                "Name": name,
                "Phone": phone,
                "Email": email,
                "Gender": gender,
              },
              onEdit: (field) {
                if (field == "Name") _editField("Name", name, (value) => setState(() => name = value));
                if (field == "Phone") _editField("Phone", phone, (value) => setState(() => phone = value));
                if (field == "Email") _editField("Email", email, (value) => setState(() => email = value));
                if (field == "Gender") _editField("Gender", gender, (value) => setState(() => gender = value));
              },
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: "Professional Details",
              details: {
                "Profession": profession,
                "Experience": experience,
                "Working Area": area,
              },
              onEdit: (field) {
                if (field == "Profession") _editField("Profession", profession, (value) => setState(() => profession = value));
                if (field == "Experience") _editField("Experience", experience, (value) => setState(() => experience = value));
                if (field == "Working Area") _editField("Working Area", area, (value) => setState(() => area = value));
              },
            ),
            const SizedBox(height: 16),
            _documentCard(),  // Updated Document Card without button
            const SizedBox(height: 16),
            _infoCard(
              title: "Address Information",
              details: {
                "Street": street,
                "City": city,
                "State": stateName,
              },
              onEdit: (field) {
                if (field == "Street") _editField("Street", street, (value) => setState(() => street = value));
                if (field == "City") _editField("City", city, (value) => setState(() => city = value));
                if (field == "State") _editField("State", stateName, (value) => setState(() => stateName = value));
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
    required Function(String) onEdit,
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
                        onPressed: () => onEdit(entry.key),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
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
          // Removed the "Verify Documents" button here.
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                          );
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
