import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(String title) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Icons.notifications,
            color: Colors.black,
          ),
        ),
          ),
    ],
  );
}