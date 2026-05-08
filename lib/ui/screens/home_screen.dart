import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:kitchen_catalogue/ui/screens/notification_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _colorForDays(int days) {
    if (days < 0) return Colors.red.shade700;              // EXPIRED
    if (days == 0) return Colors.red.shade300;             // Today
    if (days == 1) return Colors.orange.shade300;          // Tomorrow
    if (days <= 3) return Colors.yellow.shade300;          // 2–3 days
    return Colors.lightGreen.shade300;                     // 4–7 days
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
  title: const Text(
    "Home",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    ),
  ),
  backgroundColor: const Color(0xFFF1F5F9),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications, color: Color(0xFF0F172A)),
      tooltip: "Notification Settings",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationSettingsScreen(),
          ),
        );
      },
    ),
  ],
),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('locations')
            .snapshots(),
        builder: (context, locSnapshot) {
          if (!locSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final locations = locSnapshot.data!.docs;
          if (locations.isEmpty) {
            return const Center(
              child: Text(
                "No locations yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final itemStreams = locations.map((loc) {
            return FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('locations')
                .doc(loc.id)
                .collection('items')
                .snapshots();
          }).toList();

          return StreamBuilder(
            stream: _combineItemStreams(itemStreams),
            builder: (context, itemSnapshot) {
              if (!itemSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allItems = itemSnapshot.data!;
              final now = DateTime.now();

              final Map<String, List<Map<String, dynamic>>> groups = {};
              final List<Map<String, dynamic>> expiredItems = [];

              for (var item in allItems) {
                final expiration = item['expiration'] != null
                    ? (item['expiration'] as Timestamp).toDate()
                    : null;

                if (expiration == null) continue;

                final diff = expiration
                    .difference(DateTime(now.year, now.month, now.day))
                    .inDays;

                // ⭐ EXPIRED ITEMS
                if (diff < 0) {
                  expiredItems.add({
                    ...item,
                    'days': diff,
                  });
                  continue;
                }

                // ⭐ EXPIRING SOON (0–7 days)
                if (diff <= 7) {
                  String label;
                  if (diff == 0) {
                    label = "Expiring Today";
                  } else if (diff == 1) {
                    label = "Expiring Tomorrow";
                  } else {
                    label = "Expiring in $diff Days";
                  }

                  groups.putIfAbsent(label, () => []);
                  groups[label]!.add({
                    ...item,
                    'days': diff,
                  });
                }
              }

              final sortedKeys = groups.keys.toList()
                ..sort((a, b) {
                  int extractDays(String s) {
                    if (s == "Expiring Today") return 0;
                    if (s == "Expiring Tomorrow") return 1;
                    return int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));
                  }

                  return extractDays(a).compareTo(extractDays(b));
                });

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Items Expiring Soon",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ⭐ Expiring Soon Sections
                  for (final key in sortedKeys) ...[
                    Text(
                      key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...groups[key]!.map((item) {
                      final expiration =
                          (item['expiration'] as Timestamp).toDate();
                      final days = item['days'] as int;

                      return Card(
                        color: _colorForDays(days),
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Expires: ${expiration.toLocal().toString().split(' ')[0]}",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],

                  // ⭐ EXPIRED ITEMS SECTION
                  if (expiredItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Expired Items",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...expiredItems.map((item) {
                      final expiration =
                          (item['expiration'] as Timestamp).toDate();

                      return Card(
                        color: Colors.red.shade700,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "Expired: ${expiration.toLocal().toString().split(' ')[0]}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _combineItemStreams(
      List<Stream<QuerySnapshot>> streams) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    final snapshots = List<QuerySnapshot?>.filled(streams.length, null);

    for (int i = 0; i < streams.length; i++) {
      streams[i].listen((snapshot) {
        snapshots[i] = snapshot;

        final allItems = <Map<String, dynamic>>[];
        for (var snap in snapshots) {
          if (snap != null) {
            for (var doc in snap.docs) {
              allItems.add(doc.data() as Map<String, dynamic>);
            }
          }
        }

        controller.add(allItems);
      });
    }

    return controller.stream;
  }
}
