import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F609B);
  static const Color primaryDark = Color(0xFF0C4C78);
  static const Color secondary = Color(0xFF1BA6A6);
  static const Color background = Color(0xFFF4F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD6DEE8);
  static const Color textStrong = Color(0xFF122B3E);
  static const Color text = Color(0xFF2B3E53);
  static const Color textMuted = Color(0xFF5B7086);
  static const Color success = Color(0xFF1C8C45);
  static const Color warning = Color(0xFFB06E04);
  static const Color danger = Color(0xFFD94D4D);
  static const Color headingOnLight = primary;
  static const Color headingOnDark = Colors.white;

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F8FC), Color(0xFFEAF2FB), Color(0xFFF8FBFF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2A43), Color(0xFF184E77), Color(0xFF1D6FA5)],
  );

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(16, 16, 16, 20);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.manropeTextTheme().apply(
      bodyColor: text,
      displayColor: textStrong,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textStrong),
      titleTextStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: headingOnLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F7FD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(
        color: textStrong,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Color(0xFF9FC5E7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      side: const BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF1E2E3D),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF7B8DA0),
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static BoxDecoration panelDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border),
    );
  }

  static BoxDecoration mainHeadingDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10314D), Color(0xFF155C8B)],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2A1B4B70),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static Color statusColor(String status) {
    if (status == 'Resolved') return success;
    if (status == 'In Progress') return const Color(0xFF956700);
    if (status == 'Assigned') return const Color(0xFF265A8F);
    return warning;
  }

  static IconData statusIcon(String status) {
    if (status == 'Resolved') return Icons.check_circle;
    if (status == 'In Progress') return Icons.timelapse;
    if (status == 'Assigned') return Icons.assignment_ind;
    return Icons.hourglass_top;
  }

  static Color priorityColor(String priority) {
    if (priority == 'High') return const Color(0xFFC62828);
    if (priority == 'Medium') return warning;
    return success;
  }
}
