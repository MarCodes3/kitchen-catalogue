import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool enabled = true;
  List<int> daysBefore = [3];
  String notificationTime = "12:00";

  final List<int> availableDays = [1, 2, 3, 5, 7];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();

    final data = doc.data() ?? {};

    setState(() {
      enabled = data['enabled'] ?? true;
      daysBefore = List<int>.from(data['daysBefore'] ?? [3]);
      notificationTime = data['notificationTime'] ?? "12:00";
    });
  }

  Future<void> _saveSettings() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set({
      "enabled": enabled,
      "daysBefore": daysBefore,
      "notificationTime": notificationTime,
    }, SetOptions(merge: true));
  }

  Future<void> _pickTime() async {
    final parts = notificationTime.split(":");
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        notificationTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: enabled,
              onChanged: (value) {
                setState(() => enabled = value);
                _saveSettings();
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Days Before Expiration",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 8,
              children: availableDays.map((day) {
                final selected = daysBefore.contains(day);
                return ChoiceChip(
                  label: Text("$day days"),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        daysBefore.add(day);
                      } else {
                        daysBefore.remove(day);
                      }
                    });
                    _saveSettings();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              "Notification Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            ListTile(
              title: Text("Time: $notificationTime"),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
          ],
        ),
      ),
    );
  }
}
