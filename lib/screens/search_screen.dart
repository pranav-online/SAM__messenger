import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  DocumentSnapshot? _foundUser;
  bool _isLoading = false;

  Future<void> _searchUser() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    final username = _controller.text.trim();

    if (username.isEmpty) {
      setState(() {
        _error = 'Enter a username to search.';
        _foundUser = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _foundUser = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        final userDoc = query.docs.first;
        final currentUid = FirebaseAuth.instance.currentUser?.uid;

        if (userDoc.id == currentUid) {
          setState(() {
            _error = "That's you!";
            _foundUser = null;
            _isLoading = false;
          });
        } else {
          setState(() {
            _foundUser = userDoc;
            _error = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _foundUser = null;
          _error = 'No user found with that username.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Users')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Search by username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _searchUser,
                child: const Text('Search'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_error != null && !_isLoading)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_foundUser != null && !_isLoading) ...[
                const SizedBox(height: 10),
                _buildFoundUserTile(_foundUser!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoundUserTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(data['displayName'] ?? 'No name'),
      subtitle: Text('@${data['username'] ?? 'unknown'}'),
      trailing: IconButton(
        icon: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                friendUid: doc.id,
                friendUsername: data['username'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}
