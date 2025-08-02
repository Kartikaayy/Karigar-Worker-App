import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _profileImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      String? base64Image = prefs.getString('profile_image_web');
      if (base64Image != null) {
        setState(() {
          _webImageBytes = Uint8List.fromList(html.window.atob(base64Image).codeUnits);
        });
      }
    } else {
      String? imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() {
          _profileImage = File(imagePath);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        String base64Image = html.window.btoa(String.fromCharCodes(bytes));
        await prefs.setString('profile_image_web', base64Image);
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final savedImage = await File(pickedFile.path).copy('${directory.path}/profile_image.png');
        await prefs.setString('profile_image_path', savedImage.path);
        setState(() {
          _profileImage = savedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;
    if (kIsWeb) {
      avatarImage = _webImageBytes != null
          ? MemoryImage(_webImageBytes!)
          : const AssetImage('assets/avatar.png');
    } else {
      avatarImage = _profileImage != null
          ? FileImage(_profileImage!)
          : const AssetImage('assets/avatar.png');
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepOrangeAccent,
          backgroundImage: avatarImage,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
