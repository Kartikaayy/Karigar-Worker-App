import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentVerificationPage extends StatefulWidget {
  const DocumentVerificationPage({super.key});

  @override
  State<DocumentVerificationPage> createState() =>
      _DocumentVerificationPageState();
}

class _DocumentVerificationPageState extends State<DocumentVerificationPage> {
  String? aadhaarFile;
  String? photoFile;
  String? panFile;

  Future<void> pickDocument(String type) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        switch (type) {
          case 'aadhaar':
            aadhaarFile = result.files.single.name;
            break;
          case 'photo':
            photoFile = result.files.single.name;
            break;
          case 'pan':
            panFile = result.files.single.name;
            break;
        }
      });

      // Upload to server using: result.files.single.path
    }
  }

  void removeFile(String type) {
    setState(() {
      switch (type) {
        case 'aadhaar':
          aadhaarFile = null;
          break;
        case 'photo':
          photoFile = null;
          break;
        case 'pan':
          panFile = null;
          break;
      }
    });
  }

  void submitDocuments() {
    if (aadhaarFile == null || photoFile == null || panFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Upload"),
          content: const Text("Please upload all required documents."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Documents submitted successfully!")),
      );
    }
  }

  Widget documentUploadTile({
    required String title,
    required String type,
    required String? fileName,
    required VoidCallback onUpload,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload_file),
          label: Text("Upload $title"),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text("Selected: $fileName",
                      style: const TextStyle(fontSize: 14)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => removeFile(type),
                  tooltip: 'Remove $title',
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Verification")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Please upload all required documents for verification:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              documentUploadTile(
                title: "Aadhaar Card",
                type: "aadhaar",
                fileName: aadhaarFile,
                onUpload: () => pickDocument('aadhaar'),
              ),
              documentUploadTile(
                title: "Photo",
                type: "photo",
                fileName: photoFile,
                onUpload: () => pickDocument('photo'),
              ),
              documentUploadTile(
                title: "PAN Card",
                type: "pan",
                fileName: panFile,
                onUpload: () => pickDocument('pan'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitDocuments,
                  child: const Text("Submit Documents"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
