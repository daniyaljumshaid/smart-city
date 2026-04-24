import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const AnalyticsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
