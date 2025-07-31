import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/shimmer_circle.dart';
import 'status_viewer.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _statusStream() =>
      FirebaseFirestore.instance
          .collection('statuses')
          .orderBy('timestamp', descending: true)
          .snapshots();

  Future<List<String>> _friendUids() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      return List<String>.from(doc.data()?['activeChats'] ?? []);
    } catch (e) {
      print('Error getting activeChats: $e');
      return [];
    }
  }

  void _confirmDelete(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flex'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('statuses')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Flex post deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flex Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: () => Navigator.pushNamed(context, '/addStatus'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _statusStream(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const _ShimmerRow();

          return FutureBuilder<List<String>>(
            future: _friendUids(),
            builder: (c, friendSnap) {
              if (!friendSnap.hasData) return const _ShimmerRow();

              final friends = friendSnap.data!;
              final docs = friends.isEmpty
                  ? snap.data!.docs
                  : snap.data!.docs.where(
                      (d) =>
                          friends.contains(d['userId']) || d['userId'] == uid,
                    );

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    '🚀 No flex posts yet!\nBe the first to show off.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final doc = docs.elementAt(i);
                  final data = doc.data();
                  final isMe = data['userId'] == uid;
                  final base64 = data['imageBase64'];
                  final caption = data['caption'] ?? '';
                  final username = data['username'] ?? 'Guest';

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      clipBehavior: Clip.hardEdge,
                      child: ListTile(
                        leading: Hero(
                          tag: base64 ?? 'status_$i',
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: base64 != null
                                ? MemoryImage(base64Decode(base64))
                                : null,
                            child: base64 == null
                                ? const Icon(Icons.image_not_supported)
                                : null,
                          ),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isMe
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, doc.id),
                              )
                            : null,
                        onTap: base64 == null
                            ? null
                            : () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                  pageBuilder: (_, __, ___) =>
                                      StatusViewer(data: data),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    itemBuilder: (_, __) => Row(
      children: const [
        ShimmerCircle(radius: 28),
        SizedBox(width: 12),
        Expanded(child: ShimmerLine()),
      ],
    ),
    separatorBuilder: (_, __) => const SizedBox(height: 20),
    itemCount: 6,
  );
}
