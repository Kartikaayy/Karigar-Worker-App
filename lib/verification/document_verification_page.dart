import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

// ── Import your home page ────────────────────────────────────────────────────
// Update this import path to match your project structure
import '../screens/home_page.dart';

class DocumentVerificationPage extends StatefulWidget {
  const DocumentVerificationPage({super.key});

  @override
  State<DocumentVerificationPage> createState() =>
      _DocumentVerificationPageState();
}

class _DocumentVerificationPageState extends State<DocumentVerificationPage>
    with TickerProviderStateMixin {

  // ── Constants ──────────────────────────────────────────────────────────────
  static const String _baseUrl =
  // 'https://x7xxj2b799.execute-api.ap-south-1.amazonaws.com/api';
      'http://13.203.192.220:5000/api';

  // How often to poll the status API (in seconds)
  static const int _pollIntervalSeconds = 5;

  // ── State ──────────────────────────────────────────────────────────────────
  Map<String, PlatformFile?> selectedFiles = {
    'aadhar': null,
    'pan': null,
    'certifications': null,
    'policeVerification': null,
  };

  // Tracks which docs are already uploaded (from API fetch)
  Map<String, String?> uploadedUrls = {
    'aadhar': null,
    'pan': null,
    'certifications': null,
    'policeVerification': null,
  };

  String _docStatus = 'not_uploaded'; // not_uploaded | pending | verified | rejected
  bool _isSubmitting = false;
  bool _isLoadingStatus = true;
  bool _hasSubmittedBefore = false;

  Timer? _pollingTimer;
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  // ── Document config ────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> documentConfig = {
    'aadhar': {
      'title': 'Aadhaar Card',
      'icon': Icons.credit_card_rounded,
      'color': Colors.blue,
      'description': 'Upload a clear photo of your Aadhaar card',
      'required': true,
    },
    'pan': {
      'title': 'PAN Card',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Colors.green,
      'description': 'Upload a clear photo of your PAN card',
      'required': true,
    },
    'certifications': {
      'title': 'Skill Certificate',
      'icon': Icons.school_rounded,
      'color': Colors.purple,
      'description': 'Upload your technical certification',
      'required': true,
    },
    'policeVerification': {
      'title': 'Police Verification',
      'icon': Icons.security_rounded,
      'color': Colors.orange,
      'description': 'Upload your police verification certificate',
      'required': true,
    },
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _animController.forward();
    _fetchDocumentStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── API: Fetch current document status ────────────────────────────────────
  Future<void> _fetchDocumentStatus() async {
    setState(() => _isLoadingStatus = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/worker-documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final doc = data['data'];

        if (doc != null) {
          _hasSubmittedBefore = true;
          final status = doc['status'] as String? ?? 'pending';

          // Extract already-uploaded URLs
          final newUrls = <String, String?>{};
          for (final key in ['aadhar', 'pan', 'policeVerification']) {
            final field = doc[key];
            if (field is Map) {
              newUrls[key] = field['url'] as String?;
            }
          }
          // certifications is an array
          final certs = doc['certifications'];
          if (certs is List && certs.isNotEmpty) {
            newUrls['certifications'] = certs.first['url'] as String?;
          }

          if (mounted) {
            setState(() {
              _docStatus = status;
              uploadedUrls = newUrls;
              _isLoadingStatus = false;
            });
          }

          // Start/stop polling based on status
          if (status == 'pending') {
            _startPolling();
          } else {
            _stopPolling();
            if (status == 'verified') {
              _handleVerified();
            } else if (status == 'rejected') {
              _handleRejected();
            }
          }
        } else {
          // No documents uploaded yet
          if (mounted) setState(() { _docStatus = 'not_uploaded'; _isLoadingStatus = false; });
        }
      } else if (response.statusCode == 404) {
        // No document record yet
        if (mounted) setState(() { _docStatus = 'not_uploaded'; _isLoadingStatus = false; });
      } else {
        if (mounted) setState(() => _isLoadingStatus = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pulseController.repeat(reverse: true);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSeconds),
          (_) => _pollStatus(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
  }

  Future<void> _pollStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/worker-documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['data']?['status'] as String? ?? 'pending';

        if (status != _docStatus && mounted) {
          setState(() => _docStatus = status);

          if (status == 'verified') {
            _stopPolling();
            _handleVerified();
          } else if (status == 'rejected') {
            _stopPolling();
            _handleRejected();
          }
        }
      }
    } catch (_) {
      // Silent — keep polling
    }
  }

  // ── Status handlers ────────────────────────────────────────────────────────
  void _handleVerified() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.verified_rounded,
                color: Colors.green.shade600, size: 24),
          ),
          const SizedBox(width: 14),
          const Text('Verified!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Your documents have been verified by our team. You can now start accepting jobs!',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Go to Dashboard',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _handleRejected() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.cancel_outlined,
                color: Colors.red.shade600, size: 24),
          ),
          const SizedBox(width: 14),
          const Text('Documents Rejected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Your documents were rejected by our team. Please re-upload clear, valid documents and try again.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _docStatus = 'not_uploaded';
                uploadedUrls = {
                  'aadhar': null,
                  'pan': null,
                  'certifications': null,
                  'policeVerification': null,
                };
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Re-upload Documents',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── File picking ───────────────────────────────────────────────────────────
  String _getMimeType(String fileName) {
    switch (fileName.toLowerCase().split('.').last) {
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'pdf': return 'application/pdf';
      default: return 'application/octet-stream';
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          _snack('File must be under 10MB.', isError: true);
          return;
        }
        setState(() => selectedFiles[type] = file);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${documentConfig[type]!['title']} selected successfully')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _snack('Error selecting file: $e', isError: true);
    }
  }

  void _removeFile(String type) => setState(() => selectedFiles[type] = null);

  // ── Submit the doduments
  Future<void> _submit() async {
    final allReady = documentConfig.entries
        .where((e) => e.value['required'] == true)
        .every((e) =>
    selectedFiles[e.key] != null || uploadedUrls[e.key] != null);

    if (!allReady) {
      _showErrorDialog('Incomplete Upload',
          'Please upload all 4 required documents before submitting.');
      return;
    }

    final hasNew = selectedFiles.values.any((f) => f != null);
    if (!hasNew && _hasSubmittedBefore) {
      _snack('No new files selected.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final workerId = prefs.getString('workerId') ?? '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/worker-documents'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      if (workerId.isNotEmpty) request.fields['workerId'] = workerId;

      for (final entry in selectedFiles.entries) {
        final file = entry.value;
        if (file == null) continue;
        final mime = _getMimeType(file.name);
        http.MultipartFile mf;
        if (file.bytes != null) {
          mf = http.MultipartFile.fromBytes(entry.key, file.bytes!,
              filename: file.name, contentType: MediaType.parse(mime));
        } else if (file.path != null && File(file.path!).existsSync()) {
          mf = await http.MultipartFile.fromPath(entry.key, file.path!,
              filename: file.name, contentType: MediaType.parse(mime));
        } else {
          throw Exception('File data unavailable for ${entry.key}');
        }
        request.files.add(mf);
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          final newUrls = Map<String, String?>.from(uploadedUrls);
          for (final entry in selectedFiles.entries) {
            if (entry.value != null) {
              newUrls[entry.key] = entry.value!.name;
            }
          }
          setState(() {
            _docStatus = 'pending';
            _hasSubmittedBefore = true;
            uploadedUrls = newUrls;
            selectedFiles = {
              'aadhar': null,
              'pan': null,
              'certifications': null,
              'policeVerification': null,
            };
          });
          _startPolling();
          _showSuccessDialog();
        }
      } else {
        String msg = 'Submission failed';
        try { msg = jsonDecode(response.body)['message'] ?? msg; } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      _showErrorDialog('Submission Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Dialogs & snacks ───────────────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        content: Text(message,
            style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Success!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Your documents have been submitted successfully. We\'ll notify you once the admin reviews them.\n\nYou can leave this screen — we\'ll automatically take you to the dashboard once verified.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got it',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Document Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        body: _isLoadingStatus
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7043)))
            : Column(
          children: [
            // ── Header Section ─────────────────────────────────────
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
                      Icons.verified_user_rounded,
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
                          'Verify Your Identity',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload documents for account verification',
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
            ),

            // ── White rounded content area ─────────────────────────
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
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          // ── Status banner ──────────────────────
                          if (_docStatus != 'not_uploaded')
                            _buildStatusBanner(),

                          // ── Info card ──────────────────────────
                          if (_docStatus == 'not_uploaded' ||
                              _docStatus == 'rejected')
                            _buildInfoCard(),

                          // ── Document list ──────────────────────
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: documentConfig.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => _buildDocTile(
                                  e.key,
                                  e.value.key,
                                  e.value.value))
                                  .toList(),
                            ),
                          ),

                          // ── Submit button ──────────────────────
                          if (_docStatus == 'not_uploaded' ||
                              _docStatus == 'rejected')
                            _buildSubmitBar(),
                        ],
                      ),
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

  // ── Status banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner() {
    Color bg, textColor;
    IconData icon;
    String title, subtitle;

    switch (_docStatus) {
      case 'pending':
        bg = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        icon = Icons.pending_actions_outlined;
        title = 'Under Review';
        subtitle = 'Checking every ${_pollIntervalSeconds}s · Admin is reviewing your documents';
        break;
      case 'verified':
        bg = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.verified_rounded;
        title = 'Verified';
        subtitle = 'Your documents have been approved';
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.cancel_outlined;
        title = 'Rejected';
        subtitle = 'Please re-upload valid documents below';
        break;
      default:
        return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: _docStatus == 'pending' ? _pulseAnim.value : 1.0,
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.25)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (_docStatus == 'pending')
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            ),
          if (_docStatus == 'verified')
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (_) => false,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Go →',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ]),
      ),
    );
  }

  // ── Info card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7043).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7043).withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF7043).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.info_outline, color: Color(0xFFFF7043), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Document Requirements',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload clear, high-quality images or PDFs. Max 10 MB per file. All 4 documents are required.',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600, height: 1.3),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Document tile ──────────────────────────────────────────────────────────
  Widget _buildDocTile(int index, String type, Map<String, dynamic> config) {
    final selectedFile = selectedFiles[type];
    final uploadedUrl = uploadedUrls[type];
    final isUploaded = uploadedUrl != null;
    final isPending = _docStatus == 'pending';
    final isVerified = _docStatus == 'verified';
    final color = config['color'] as Color;

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        ((index * 0.1) + 0.3).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        child: Material(
          elevation: 3,
          shadowColor: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  color.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.1),
                          color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      config['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(config['title'] as String,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Required',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(config['description'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  // Status indicator
                  if (isVerified && isUploaded)
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green.shade600, size: 20)
                  else if (isPending && isUploaded)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.amber.shade600),
                    ),
                ]),

                const SizedBox(height: 16),

                // File section
                if (selectedFile != null) ...[
                  _buildSelectedFileCard(type, selectedFile, color,
                      canRemove: !(isPending || isVerified)),
                ] else if (isUploaded) ...[
                  _buildUploadedChip(color, isPending, isVerified),
                ] else ...[
                  _buildUploadButton(type, color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(String type, Color color) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _pickFile(type),
        icon: Icon(Icons.cloud_upload_rounded, color: color),
        label: Text(
          'Select File',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(String type, PlatformFile file, Color color,
      {required bool canRemove}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle_outline,
                color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB · new',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: () => _removeFile(type),
              icon: Icon(Icons.close_rounded, color: Colors.red.shade600),
              iconSize: 20,
              tooltip: 'Remove file',
            ),
        ],
      ),
    );
  }

  Widget _buildUploadedChip(Color color, bool isPending, bool isVerified) {
    final chipColor = isVerified ? Colors.green.shade600 : Colors.amber.shade700;
    final chipBg = isVerified ? Colors.green.shade50 : Colors.amber.shade50;
    final label = isPending ? 'Awaiting admin review' : isVerified ? 'Verified ✓' : 'Upload confirmed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.insert_drive_file_outlined, size: 18, color: chipColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document uploaded',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: chipColor)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: chipColor.withOpacity(0.75))),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Submit bar ─────────────────────────────────────────────────────────────
  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8)),
            ),
          )
              : const Icon(Icons.send_rounded),
          label: Text(
            _isSubmitting ? 'Submitting...' : 'Submit Documents',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7043),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28)),
            elevation: 4,
          ),
        ),
      ),
    );
  }
}