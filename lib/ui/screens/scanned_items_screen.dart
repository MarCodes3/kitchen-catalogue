import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScannedItemsScreen extends StatelessWidget {
  const ScannedItemsScreen({super.key});

  void _openScanMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text("Scan Barcode"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/scan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text("Scan Receipt"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/receipt');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("More Scan Options"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Scanned Items")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan"),
        onPressed: () => _openScanMenu(context),
      ),

      // ⭐ Load from known_items (persistent scanned item names)
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('known_items')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No scanned items yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final name = doc['name'];

              return ListTile(
                title: Text(name),

                // ⭐ Edit item name
                leading: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, doc.id, name);
                  },
                ),

                // ⭐ Delete item
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('known_items')
                        .doc(doc.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ⭐ Edit dialog for renaming scanned items
  void _showEditDialog(BuildContext context, String docId, String currentName) {
    final controller = TextEditingController(text: currentName);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item Name"),
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
                    .doc(uid)
                    .collection('known_items')
                    .doc(docId)
                    .set({
                  'name': newName,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
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
