import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String friendUid;
  final String friendUsername;

  const ChatScreen({
    super.key,
    required this.friendUid,
    required this.friendUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  bool _isGenerating = false;

  String getChatRoomId() {
    final uids = [currentUid, widget.friendUid]..sort();
    return '${uids[0]}_${uids[1]}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatRoomId = getChatRoomId();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatDocRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId);

    final chatDoc = await chatDocRef.get();

    final users = [currentUser.uid, widget.friendUid];
    final usernames = [
      currentUser.displayName ?? currentUser.email ?? 'You',
      widget.friendUsername,
    ];

    if (!chatDoc.exists) {
      await chatDocRef.set({
        'users': users..sort(),
        'usernames': usernames,
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDocRef.update({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await chatDocRef.collection('messages').add({
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();

    final messagesSnapshot = await chatDocRef.collection('messages').get();
    final isFirstMessage = messagesSnapshot.docs.length == 1;

    if (isFirstMessage) {
      final usersRef = FirebaseFirestore.instance.collection('users');
      await usersRef.doc(currentUid).update({
        'activeChats': FieldValue.arrayUnion([widget.friendUid]),
      });
      await usersRef.doc(widget.friendUid).update({
        'activeChats': FieldValue.arrayUnion([currentUid]),
      });
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  Future<void> _generateReply() async {
    setState(() => _isGenerating = true);

    final chatRoomId = getChatRoomId();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final lastMessage = querySnapshot.docs.first.data();
      final lastText = lastMessage['text'] ?? '';

      final aiResponse = await _callOllamaApi(lastText);

      if (mounted) {
        setState(() => _messageController.text = aiResponse.trim());
      }
    } catch (e) {
      debugPrint('⚠️ Ollama error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Failed to generate AI reply')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<String> _callOllamaApi(String input) async {
    const endpoint = 'http://localhost:11434/api/generate'; // Replace if needed

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "llama2",
        "prompt": "Reply to this message in a friendly tone: \"$input\"",
        "stream": true,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get AI response');
    }

    final lines = response.body.split('\n');
    String fullReply = '';

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final jsonLine = jsonDecode(line);
      fullReply += jsonLine['response'] ?? '';
    }

    return fullReply;
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId();

    return Scaffold(
      appBar: AppBar(title: Text(widget.friendUsername)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.deepPurple
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTimestamp(msg['timestamp']),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.1),
              ),
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
