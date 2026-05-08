import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isProcessing = false;

  Future<void> _simulateScan() async {
    if (isProcessing) return;
    isProcessing = true;

    // Simulated barcode value
    const barcode = "TEST-BARCODE-12345";

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scanned_items')
        .add({
      'barcode': barcode,
      'name': 'Unknown Item',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Item")),
      body: Center(
        child: ElevatedButton(
          onPressed: _simulateScan,
          child: const Text("Simulate Scan"),
        ),
      ),
    );
  }
}
