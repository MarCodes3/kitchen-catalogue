import 'package:flutter/material.dart';

enum BottomTab { home, inventory, shopping, scan }

class BottomNavBar extends StatelessWidget {
  final BottomTab active;

  const BottomNavBar({super.key, required this.active});

  Color _colorFor(BottomTab tab) {
    if (tab == active) {
      if (tab == BottomTab.inventory) return const Color(0xFF0284C7);
      if (tab == BottomTab.shopping) return const Color(0xFF059669);
      if (tab == BottomTab.scan) return const Color(0xFF0F172A);
      return const Color(0xFF0F172A);
    }
    return const Color(0xFF9CA3AF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home_filled, 'Home', BottomTab.home),
          _item(Icons.inventory_2_rounded, 'Inventory', BottomTab.inventory),
          _item(Icons.list_alt_rounded, 'Shopping', BottomTab.shopping),
          _item(Icons.camera_alt_rounded, 'Scan', BottomTab.scan),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, BottomTab tab) {
    final color = _colorFor(tab);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: tab == active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
