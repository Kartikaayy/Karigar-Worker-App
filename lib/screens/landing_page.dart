import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../verification/document_verification_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool documentsSubmitted = false;
  bool documentsVerified = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      documentsSubmitted = prefs.getBool('documentsSubmitted') ?? false;
      documentsVerified = prefs.getBool('documentsVerified') ?? false;
    });

    if (documentsSubmitted && !documentsVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVerificationPendingDialog();
      });
    }
  }

  Future<void> _updateVerificationStatus({required bool submitted, required bool verified}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('documentsSubmitted', submitted);
    await prefs.setBool('documentsVerified', verified);
    setState(() {
      documentsSubmitted = submitted;
      documentsVerified = verified;
    });
  }

  void _resetVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('documentsSubmitted');
    await prefs.remove('documentsVerified');
    setState(() {
      documentsSubmitted = false;
      documentsVerified = false;
    });
  }

  void _showVerificationPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Documents Under Verification"),
        content: const Text("Your documents have been submitted and are under verification. You will be notified once verified."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _navigateToDocumentVerification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentVerificationPage()),
    );

    if (result == true) {
      await _updateVerificationStatus(submitted: true, verified: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = documentsSubmitted && documentsVerified;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upper Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome to Karigar App!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your trusted service partner.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          documentsSubmitted
                              ? (isVerified
                              ? "Your documents are verified. You can now start services."
                              : "Documents are under verification.")
                              : "To start services, upload your documents first.",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: documentsSubmitted
                          ? (isVerified
                          ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                          : null)
                          : _navigateToDocumentVerification,
                      child: Text(
                        documentsSubmitted
                            ? (isVerified ? 'Go to Home Page' : 'Awaiting Verification...')
                            : 'Upload Documents',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // -------- TEMPORARY BUTTONS (Remove in Production) --------
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: _resetVerificationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'Reset Verification', // <-- TEMPORARY RESET BUTTON
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'Go to Home Page', // <-- TEMPORARY DIRECT ACCESS BUTTON
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            // ---------------------------------------------------------
          ],
        ),
      ),
    );
  }
}
