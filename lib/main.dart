import 'package:classicon_vs_code/screens/city_analytics.dart';
import 'package:classicon_vs_code/screens/emergency_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart City App',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const CityAnalyticsScreen(),
    );
  }
}
