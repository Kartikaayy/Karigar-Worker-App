import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../verification/document_verification_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  bool documentsSubmitted = false;
  bool documentsVerified = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadVerificationStatus();
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  Future<void> _updateVerificationStatus(
      {required bool submitted, required bool verified}) async {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pending_actions_rounded,
                  color: Colors.orange.shade600, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Under Verification",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Your documents have been submitted and are being reviewed by our team. You'll receive a notification once the verification is complete.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
    final screenHeight = MediaQuery.of(context).size.height;

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
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        height: screenHeight * 0.55, // slightly reduced
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.handyman_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Karigar App!',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your trusted service partner.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Status Section
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: SingleChildScrollView( // ✅ FIX
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Status Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _getStatusGradient(),
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          _getStatusColor().withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                            Colors.white.withOpacity(0.2),
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            _getStatusIcon(),
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _getStatusTitle(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _getStatusDescription(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                            Colors.white.withOpacity(0.9),
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: documentsSubmitted && !isVerified
                                        ? _buildPendingButton()
                                        : _buildActionButton(),
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
              ),

              // Debug Buttons
              // Positioned(
              //   top: 16,
              //   left: 16,
              //   child: _debugResetButton(),
              // ),
              // Positioned(
              //   top: 16,
              //   right: 16,
              //   child: _debugSkipButton(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Debug Buttons ---
  // Widget _debugResetButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.red.withOpacity(0.9),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: _resetVerificationStatus,
  //         borderRadius: BorderRadius.circular(12),
  //         child: const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //           child: Text(
  //             'Reset',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _debugSkipButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.green.withOpacity(0.9),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: () {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => const HomePage()),
  //           );
  //         },
  //         borderRadius: BorderRadius.circular(12),
  //         child: const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //           child: Text(
  //             'Skip',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // --- Status Helpers ---
  List<Color> _getStatusGradient() {
    if (documentsVerified) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (documentsSubmitted) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [const Color(0xFFFF7043), const Color(0xFFFF8A65)];
    }
  }

  Color _getStatusColor() {
    if (documentsVerified) {
      return Colors.green;
    } else if (documentsSubmitted) {
      return Colors.orange;
    } else {
      return const Color(0xFFFF7043);
    }
  }

  IconData _getStatusIcon() {
    if (documentsVerified) {
      return Icons.verified_rounded;
    } else if (documentsSubmitted) {
      return Icons.pending_actions_rounded;
    } else {
      return Icons.upload_file_rounded;
    }
  }

  String _getStatusTitle() {
    if (documentsVerified) {
      return 'Verification Complete!';
    } else if (documentsSubmitted) {
      return 'Under Review';
    } else {
      return 'Get Started';
    }
  }

  String _getStatusDescription() {
    if (documentsVerified) {
      return 'Your documents are verified. You can now start providing services and earning money!';
    } else if (documentsSubmitted) {
      return 'Your documents are being reviewed by our team. We\'ll notify you once verification is complete.';
    } else {
      return 'To start providing services, please upload your documents for verification first.';
    }
  }

  // --- Buttons ---
  Widget _buildActionButton() {
    final isVerified = documentsSubmitted && documentsVerified;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVerified
              ? [Colors.green.shade400, Colors.green.shade600]
              : [const Color(0xFFFF7043), const Color(0xFFFF8A65)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.green : const Color(0xFFFF7043))
                .withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isVerified
            ? () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
            : _navigateToDocumentVerification,
        icon: Icon(
          isVerified ? Icons.home_rounded : Icons.upload_file_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          isVerified ? 'Go to Dashboard' : 'Upload Documents',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade500],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Verification in Progress...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
