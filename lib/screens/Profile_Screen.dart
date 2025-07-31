import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  Uint8List? _imageBytes; // Picked image bytes
  String? _base64Saved; // Saved base64 string
  bool _saving = false;

  /* ─── Pick image with compression ─── */
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 60, // Compress (0-100)
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
      debugPrint('✅ Picked & compressed image: ${bytes.lengthInBytes} bytes');
    }
  }

  /* ─── Save to Firestore ─── */
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    String? base64Img = _base64Saved;

    if (_imageBytes != null) {
      base64Img = base64Encode(_imageBytes!);
      debugPrint('✅ Final base64 length: ${base64Img.length}');
    }

    final username = _usernameController.text.trim();
    debugPrint('🔧 Saving username: $username');

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      if (username.isNotEmpty) 'username': username,
      if (base64Img != null) 'profilePicBase64': base64Img,
    });

    setState(() {
      _saving = false;
      _base64Saved = base64Img;
      _imageBytes = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Profile updated')));
  }

  /* ─── Load from Firestore ─── */
  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      _usernameController.text = data['username'] ?? '';
      _base64Saved = data['profilePicBase64'];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /* ─── UI ─── */
  @override
  Widget build(BuildContext context) {
    Uint8List? displayImage;
    try {
      displayImage =
          _imageBytes ??
          (_base64Saved != null ? base64Decode(_base64Saved!) : null);
    } catch (e) {
      debugPrint('❌ Error decoding base64 image: $e');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (displayImage != null)
                    ? MemoryImage(displayImage)
                    : null,
                child: displayImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
          ],
        ),
      ),
    );
  }
}
