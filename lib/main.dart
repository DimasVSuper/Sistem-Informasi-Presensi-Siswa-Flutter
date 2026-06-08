import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // Ensure widget bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian locale formatting
  await initializeDateFormatting('id_ID', null);
  
  runApp(const AttendanceScannerApp());
}

class AttendanceScannerApp extends StatelessWidget {
  const AttendanceScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Attendance Scanner',
      debugShowCheckedModeBanner: false,
      
      // Gorgeous Dark Theme (Default)
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
