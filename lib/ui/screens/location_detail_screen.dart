import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_item_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationId;
  final String locationName;

  const LocationDetailScreen({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
      ),

      // ⭐ FAB is now the ONLY Add Item button
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(locationId: widget.locationId),
            ),
          );
        },
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('locations')
            .doc(widget.locationId)
            .collection('items')
            .orderBy('expiration')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No items in this location yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final expiration = data['expiration'] != null
                  ? (data['expiration'] as Timestamp).toDate()
                  : null;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: expiration != null
                      ? Text(
                          "Expires: ${expiration.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(color: Colors.grey),
                        )
                      : const Text("No expiration date"),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('locations')
                          .doc(widget.locationId)
                          .collection('items')
                          .doc(doc.id)
                          .delete();
                    },
                  ),

                  // ⭐ Optional: enable editing
                   onTap: () => _editItem(context, doc.id, name, expiration),
                ),
              );
            },
          );
        },
      ),
    );
  }

  
  void _editItem(BuildContext context, String itemId, String currentName, DateTime? expiration) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Item name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('locations')
                    .doc(widget.locationId)
                    .collection('items')
                    .doc(itemId)
                    .update({'name': newName});
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
  
}
