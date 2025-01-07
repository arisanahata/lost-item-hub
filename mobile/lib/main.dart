import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view/page/home/home_screen.dart';
import 'model/entities/draft_item.dart';
import 'model/repositories/local/item_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveの初期化
  await Hive.initFlutter();

  // アダプターの登録（未登録の場合のみ）
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DraftItemAdapter());
  }

  // ItemRepositoryの初期化
  final repository = ItemRepository();
  await repository.init();

  runApp(
    ProviderScope(
      overrides: [
        // ローカルストレージのリポジトリを初期化
        itemRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '忘れ物登録アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 12, 51, 135),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
          iconTheme: IconThemeData(
            color: Colors.grey[800],
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        textTheme: GoogleFonts.notoSansTextTheme().copyWith(
          titleLarge: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
          titleMedium: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 12, 51, 135), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[300]!),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
