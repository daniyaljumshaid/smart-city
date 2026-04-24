import 'package:flutter/material.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SOSButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 124,
        width: 124,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4B4B), Color(0xFFD32222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "SOS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
