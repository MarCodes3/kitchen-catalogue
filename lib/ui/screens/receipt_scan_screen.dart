import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  File? _image;
  bool _loading = false;

  // Resize image before OCR (huge speed boost)
  Future<File> _resizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1024);
    final frame = await codec.getNextFrame();
    final resized = frame.image;

    final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
    final resizedBytes = byteData!.buffer.asUint8List();

    final resizedFile = File(file.path.replaceAll(".jpg", "_small.png"));
    await resizedFile.writeAsBytes(resizedBytes);

    return resizedFile;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    setState(() {
      _loading = true;
    });

    final resized = await _resizeImage(File(picked.path));
    await _processReceipt(resized);

    setState(() => _loading = false);
  }

  Future<void> _processReceipt(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    textRecognizer.close();

    final parsed = _parseReceipt(recognizedText.text);

    // Clear image BEFORE navigating to avoid ghost UI
    setState(() {
      _image = null;
    });

    // Navigate immediately (fast UX)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptResultScreen(items: parsed),
        ),
      );
    }

    // Save in background (non-blocking)
    _saveReceipt(parsed);
    _saveKnownItems(parsed);
  }

  // ⭐ Optimized parser with price filtering
  List<Map<String, dynamic>> _parseReceipt(String text) {
    final lines = text.split('\n');
    final items = <Map<String, dynamic>>[];

    String? pendingName;

    final priceRegex = RegExp(r'[\$]?(\d+(?:\.\d{1,2})?)');

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final priceMatch = priceRegex.firstMatch(line);

      if (priceMatch != null) {
        final price = double.tryParse(priceMatch.group(1)!) ?? 0.0;

        if (pendingName != null) {
          items.add({
            'name': pendingName!,
            'price': price,
          });
          pendingName = null;
        } else {
          final name = line.replaceAll(priceMatch.group(0)!, '').trim();

          // Skip numeric-only names
          if (name.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(name)) {
            items.add({
              'name': name,
              'price': price,
            });
          }
        }
      } else {
        // Only treat as item name if it contains letters
        if (RegExp(r'[A-Za-z]').hasMatch(line)) {
          pendingName = line;
        }
      }
    }

    return items;
  }

  Future<void> _saveReceipt(List<Map<String, dynamic>> items) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('receipts')
        .add({
      'items': items,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ⭐ Skip numeric-only names (prevents prices from being saved)
  Future<void> _saveKnownItems(List<Map<String, dynamic>> items) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('known_items');

    for (var item in items) {
      final name = item['name'].toString().trim();

      if (!RegExp(r'[A-Za-z]').hasMatch(name)) continue;

      ref.doc(name.toLowerCase()).set({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Receipt")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Scan Receipt"),
              ),
      ),
    );
  }
}

class ReceiptResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ReceiptResultScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt Results")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item['name']),
            trailing: Text("\$${item['price'].toStringAsFixed(2)}"),
          );
        },
      ),
    );
  }
}
