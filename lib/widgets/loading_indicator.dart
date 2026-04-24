import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Loading..."),
        SizedBox(height: 10),
        LinearProgressIndicator(),
      ],
    );
  }
}
