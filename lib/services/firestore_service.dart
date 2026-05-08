import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Create user root
  Future<void> createUserRoot() async {
    final userRef = _db.collection('users').doc(uid);

    await userRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'email': FirebaseAuth.instance.currentUser!.email,
    }, SetOptions(merge: true));
  }

  // Add location
  Future<void> addLocation(String name) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('locations')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream locations
  Stream<QuerySnapshot> getLocations() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('locations')
        .orderBy('createdAt')
        .snapshots();
  }

  // Add item to location
  Future<void> addItem(String locationId, String name, DateTime expiration) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('locations')
        .doc(locationId)
        .collection('items')
        .add({
      'name': name,
      'expiration': expiration,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream items in a location
  Stream<QuerySnapshot> getItems(String locationId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('locations')
        .doc(locationId)
        .collection('items')
        .orderBy('expiration')
        .snapshots();
  }

  // Add shopping list item
  Future<void> addShoppingListItem(String name) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream shopping list
  Stream<QuerySnapshot> getShoppingList() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .orderBy('createdAt')
        .snapshots();
  }

  // Add scanned item
  Future<void> addScannedItem(String name, String barcode) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('scannedItems')
        .add({
      'name': name,
      'barcode': barcode,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream scanned items
  Stream<QuerySnapshot> getScannedItems() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('scannedItems')
        .orderBy('createdAt')
        .snapshots();
  }
}
