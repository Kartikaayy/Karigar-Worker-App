import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../widgets/profile_image_picker.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
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
    // About section fields
    "bio": "Experienced professional dedicated to delivering quality service",
    "skills": "Plumbing, Pipe fitting, Water systems",
    "experienceYears": "5",
  };

  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadProfileData();
    _fetchProfileFromAPI();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _fetchProfileFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      _handleApiError({'error': 'no_token', 'message': 'No token found.'});
      setState(() {
        _isLoading = false;
      });
      return;
    }

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
    _animationController.forward();
  }

  void _updateProfileState(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        profileData["name"] = data["name"]?.toString() ?? profileData["name"]!;
        profileData["phone"] = data["phone"]?.toString() ?? profileData["phone"]!;
        profileData["email"] = data["email"]?.toString() ?? profileData["email"]!;
        profileData["gender"] = data["gender"]?.toString() ?? profileData["gender"]!;
        // Update about section if available in API response
        profileData["bio"] = data["bio"]?.toString() ?? profileData["bio"]!;
        profileData["skills"] = (data["skills"] as List<dynamic>?)?.join(", ") ?? profileData["skills"]!;
        profileData["experienceYears"] = data["experienceYears"]?.toString() ?? profileData["experienceYears"]!;
      });
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
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
        // Load about section data
        profileData["bio"] = prefs.getString('bio') ?? profileData["bio"]!;
        profileData["skills"] = prefs.getString('skills') ?? profileData["skills"]!;
        profileData["experienceYears"] = prefs.getString('experienceYears') ?? profileData["experienceYears"]!;
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
    // Save about section data
    prefs.setString('bio', profileData["bio"]!);
    prefs.setString('skills', profileData["skills"]!);
    prefs.setString('experienceYears', profileData["experienceYears"]!);
  }

  void _handleApiError(Map<String, dynamic> error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text("Error: ${error['message']}")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
              ),
            ),
            maxLines: field == "Bio" ? 3 : 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );

    if (newText != null && newText.isNotEmpty && newText != currentValue) {
      setState(() {
        profileData[field.toLowerCase()] = newText;
      });
      _saveProfileData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text("$field updated successfully!"),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
                          Icons.person_rounded,
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
                              'Profile',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your account information',
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
                  child: _isLoading
                      ? _buildLoadingState()
                      : _buildProfileContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8F5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
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
              'Loading profile...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8F5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture and Basic Info
              _buildAnimatedCard(
                delay: 100,
                child: Column(
                  children: [
                    const ProfileImagePicker(),
                    const SizedBox(height: 16),
                    Text(
                      profileData["name"]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF7043).withOpacity(0.1),
                            const Color(0xFFFF7043).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF7043).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.work_rounded, color: const Color(0xFFFF7043), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            profileData["profession"]!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF7043),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information
              _buildAnimatedCard(
                delay: 200,
                child: _buildInfoCard(
                  title: "Personal Information",
                  icon: Icons.person_outline_rounded,
                  details: {
                    "Name": profileData["name"]!,
                    "Phone": profileData["phone"]!,
                    "Email": profileData["email"]!,
                    "Gender": profileData["gender"]!,
                  },
                ),
              ),

              const SizedBox(height: 20),

              // About Section
              _buildAnimatedCard(
                delay: 300,
                child: _buildInfoCard(
                  title: "About",
                  icon: Icons.info_outline_rounded,
                  details: {
                    "Bio": profileData["bio"]!,
                    "Skills": profileData["skills"]!,
                    "Experience Years": profileData["experienceYears"]!,
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Account Settings
              _buildAnimatedCard(
                delay: 400,
                child: _buildAccountSettingsCard(),
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String> details,
  }) {
    return Material(
      elevation: 6,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
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
                        const Color(0xFFFF7043).withOpacity(0.1),
                        const Color(0xFFFF7043).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFFF7043), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...details.entries.map((entry) => _buildDetailRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
              maxLines: label == "Bio" ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              size: 18,
              color: const Color(0xFFFF7043),
            ),
            onPressed: () => _editField(label, value),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Material(
      elevation: 6,
      shadowColor: const Color(0xFFFF7043).withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
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
                        const Color(0xFFFF7043).withOpacity(0.1),
                        const Color(0xFFFF7043).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings_rounded, color: const Color(0xFFFF7043), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Account Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsRow("Notification Settings", "Enabled", Icons.notifications_rounded),
            _buildSettingsRow("Privacy & Security", "Standard", Icons.security_rounded),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showLogoutDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade50,
                          Colors.red.shade100.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red.shade400, Colors.red.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Sign out of your account",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.red.shade600),
                        ),
                      ],
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

  Widget _buildSettingsRow(String setting, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF7043), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              setting,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
  }
}