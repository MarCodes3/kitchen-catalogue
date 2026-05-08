import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'location_detail_screen.dart';

// ⭐ ADD THIS IMPORT
import 'add_item_screen.dart';

class LocationsScreen extends StatelessWidget {
  LocationsScreen({super.key});

  final service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "Locations",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: service.getLocations(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No locations yet",
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

                    // ⭐ Add Item button for each location
                    subtitle: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddItemScreen(
                              locationId: doc.id,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Add Item",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    trailing: const Icon(Icons.chevron_right_rounded),

                    // Existing navigation to Location Detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationDetailScreen(
                            locationId: doc.id,
                            locationName: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),

      // Existing Add Location button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Location"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Location name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                service.addLocation(text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
