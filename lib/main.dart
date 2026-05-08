import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ui/screens/scan_screen.dart';
import 'ui/screens/receipt_scan_screen.dart';
import 'ui/app_navigator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    await FirebaseAuth.instance.signInAnonymously();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    runApp(const KitchenCatalogueApp());
  } catch (e, stack) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Startup error:\n$e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}


class KitchenCatalogueApp extends StatelessWidget {
  const KitchenCatalogueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Catalogue',
      debugShowCheckedModeBanner: false,
      routes: {
        '/scan': (_) => ScanScreen(),
        '/receipt': (_) => ReceiptScanScreen(),
      },
      theme: ThemeData(
        fontFamily: 'SF Pro Text',
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}
