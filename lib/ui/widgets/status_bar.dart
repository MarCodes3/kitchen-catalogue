import 'package:flutter/material.dart';

class IOSStatusBar extends StatelessWidget {
  const IOSStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_4_bar, size: 14, color: Color(0xFF0F172A)),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 14, color: Color(0xFF0F172A)),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 14, color: Color(0xFF0F172A)),
            ],
          ),
        ],
      ),
    );
  }
}
