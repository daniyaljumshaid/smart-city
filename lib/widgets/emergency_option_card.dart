import 'package:flutter/material.dart';

class EmergencyOptionCard extends StatelessWidget {
  final IconData icon;
  final String title1;
  final String title2;
  final VoidCallback? onTap;
  final Color accentColor;

  const EmergencyOptionCard({
    required this.icon,
    required this.title1,
    required this.title2,
    this.onTap,
    this.accentColor = const Color(0xFFE53935),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: accentColor.withOpacity(0.14),
              child: Icon(icon, size: 25, color: accentColor),
            ),
            const SizedBox(height: 10),
            Text(
              title1,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5E6C76)),
            ),
          ],
        ),
      ),
    );
  }
}
