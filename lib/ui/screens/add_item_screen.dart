import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItemScreen extends StatefulWidget {
  final String locationId;

  const AddItemScreen({super.key, required this.locationId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _expiration;
  List<String> _knownItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadKnownItems();
  }

  Future<void> _loadKnownItems() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('known_items')
        .orderBy('name')
        .get();

    setState(() {
      _knownItems = snapshot.docs.map((d) => d['name'] as String).toList();
      _loading = false;
    });
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();

    if (name.isEmpty || _expiration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name and expiration date")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1️⃣ Save item to the selected location
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('locations')
        .doc(widget.locationId)
        .collection('items')
        .add({
      'name': name,
      'expiration': _expiration,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ Remove from scanned items list (known_items)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('known_items')
        .doc(name.toLowerCase())
        .delete()
        .catchError((_) {
          // If the item wasn't in known_items, ignore the error
        });

    // 3️⃣ Close screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Dropdown of known scanned items
                  DropdownButtonFormField<String>(
                    items: _knownItems
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _nameController.text = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Scanned Item",
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Manual entry
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Item Name (manual)",
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Expiration date picker
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _expiration = picked);
                      }
                    },
                    child: Text(
                      _expiration == null
                          ? "Pick Expiration Date"
                          : "Expires: ${_expiration!.toLocal()}".split(" ")[0],
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text("Add Item"),
                  ),
                ],
              ),
            ),
    );
  }
}
