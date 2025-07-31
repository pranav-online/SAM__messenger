import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';
import 'search_screen.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final currentUser = FirebaseAuth.instance.currentUser;

  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    return now.difference(timestamp).inDays == 0
        ? DateFormat('hh:mm a').format(timestamp)
        : DateFormat('dd MMM').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = currentUser?.uid;
    if (myUid == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        icon: const Icon(Icons.search),
        label: const Text('Search Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: myUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('ChatTab error: ${snapshot.error}');
            return const Center(child: Text('Something went wrong!'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No chats yet. Start one!'));
          }

          docs.sort((a, b) {
            final aTime =
                (a['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};

              final users = List<String>.from(data['users'] ?? []);
              final usernames = List<String>.from(data['usernames'] ?? []);
              final lastMsg = data['lastMessage'] ?? '';
              final updatedAt = (data['lastUpdated'] as Timestamp?)?.toDate();

              if (users.length < 2 || usernames.length < 2) {
                return const SizedBox(); // skip malformed document
              }

              final friendIdx = users.indexOf(myUid) == 0 ? 1 : 0;

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(usernames[friendIdx]),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  formatTimestamp(updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      friendUid: users[friendIdx],
                      friendUsername: usernames[friendIdx],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
