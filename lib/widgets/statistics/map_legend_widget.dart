import 'package:flutter/material.dart';

class MapLegendWidget extends StatelessWidget {
  const MapLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Güçlü (%80+)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.extension, color: const Color(0xFFFFC107), size: 18),
                const SizedBox(width: 4),
                Text(
                  'Gelişime Açık (%50-80)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xFFD32F2F),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kritik Eksik (<%50)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
