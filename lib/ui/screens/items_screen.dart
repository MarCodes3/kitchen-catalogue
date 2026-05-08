import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ItemsScreen extends StatelessWidget {
  final String locationId;
  final service = FirestoreService();

  ItemsScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body: StreamBuilder(
        stream: service.getItems(locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No items yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final expiration = data['expiration']?.toDate();

              return ListTile(
                title: Text(name),
                subtitle: expiration != null
                    ? Text("Expires: ${expiration.toString().split(' ')[0]}")
                    : const Text("No expiration date"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Item name"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );

                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? "Select expiration date"
                        : "Expires: ${selectedDate.toString().split(' ')[0]}",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty &&
                      selectedDate != null) {
                    service.addItem(
                      locationId,
                      nameController.text.trim(),
                      selectedDate!,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }
}
