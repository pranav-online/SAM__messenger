import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddStatusScreen extends StatefulWidget {
  const AddStatusScreen({super.key});

  @override
  State<AddStatusScreen> createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  Uint8List? _imageBytes;
  String? _base64Image;
  final _captionController = TextEditingController();
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Resize to reduce size
      maxHeight: 600,
      imageQuality: 60, // Compress to JPEG ~60%
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _base64Image = base64Encode(bytes);
      });
      debugPrint('✅ Image selected, base64 size: ${_base64Image!.length}');
    }
  }

  Future<void> _uploadStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_base64Image == null || user == null) return;

    setState(() => _uploading = true);

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('statuses').add({
      'userId': user.uid,
      'username': userData['username'] ?? 'User',
      'caption': _captionController.text.trim(),
      'imageBase64': _base64Image,
      'timestamp': Timestamp.now(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flex')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageBytes == null
                  ? Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_photo_alternate, size: 50),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _imageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _uploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _uploadStatus,
                    icon: const Icon(Icons.upload),
                    label: const Text('Post Flex'),
                  ),
          ],
        ),
      ),
    );
  }
}
