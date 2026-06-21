import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/dashboard_screen.dart';

// FUNGSI UTAMA: Ini adalah titik awal aplikasi berjalan (seperti pintu masuk rumah)
void main() async {
  // Pastikan sistem flutter siap sebelum aplikasi jalan
  WidgetsFlutterBinding.ensureInitialized();
  
  // Format tanggal pakai bahasa Indonesia (id_ID)
  await initializeDateFormatting('id_ID', null);
  
  // Jalankan aplikasi dengan nama AttendanceScannerApp
  runApp(const AttendanceScannerApp());
}

class AttendanceScannerApp extends StatelessWidget {
  const AttendanceScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah wadah/pembungkus seluruh halaman aplikasi
    return MaterialApp(
      title: 'QR Attendance Scanner',
      debugShowCheckedModeBanner: false, // Sembunyikan pita "DEBUG" di pojok kanan atas
      
      // Tema aplikasi disesuaikan dengan settingan HP (Terang/Gelap)
      themeMode: ThemeMode.system,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.purple,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.purple.shade400,
          background: const Color(0xFF0F0F1A),
          surface: const Color(0xFF1E1E2E),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1E1E2E),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      
      home: const DashboardScreen(),
    );
  }
}
