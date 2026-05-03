import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_gate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 370;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -65,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmall ? 110 : 126,
                            height: isSmall ? 110 : 126,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: Colors.white.withOpacity(0.95),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 28,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                color: const Color(0xFFEAF4FF),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_city_outlined,
                                    size: 54,
                                    color: Color(0xFF1B7CB6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Smart City',
                            style: TextStyle(
                              fontSize: isSmall ? 30 : 34,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.headingOnDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Management System',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD7EDFF),
                            ),
                          ),
                          const SizedBox(height: 38),
                          const Text(
                            'Connecting citizens with better services',
                            style: TextStyle(
                              color: Color(0xFFBFE0F8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: const LinearProgressIndicator(
                                minHeight: 6,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF87D1FF),
                                ),
                                backgroundColor: Color(0x335C9ECC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
