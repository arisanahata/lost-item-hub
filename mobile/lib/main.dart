import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/lost_item/presentation/screens/lost_item_form_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost Item Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a56db),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme().copyWith(
          titleLarge: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
          titleMedium: GoogleFonts.notoSans(
            fontSize: 18,
            color: Colors.grey[800],
          ),
          bodyLarge: GoogleFonts.notoSans(
            fontSize: 18,
            color: Colors.grey[900],
          ),
          bodyMedium: GoogleFonts.notoSans(
            fontSize: 16,
            color: Colors.grey[800],
          ),
          bodySmall: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.notoSans(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          floatingLabelStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          hintStyle: GoogleFonts.notoSans(
            fontSize: 18,
            color: Colors.grey[500],
          ),
          errorStyle: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.red[700],
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF1a56db)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.red[300]!),
          ),
        ),
      ),
      home: LostItemFormScreen(),
    );
  }
}
