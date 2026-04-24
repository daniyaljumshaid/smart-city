import 'package:flutter/material.dart';

class SummaryBox extends StatelessWidget {
  final int total;
  final int resolved;

  const SummaryBox({required this.total, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Total Complaints: $total"),
        Text("Resolved Complaints: $resolved"),
      ],
    );
  }
}
