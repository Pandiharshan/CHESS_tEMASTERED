import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  runApp(const ChessRemasteredApp());
}

class ChessRemasteredApp extends StatelessWidget {
  const ChessRemasteredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Remastered',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Courier', 
        colorScheme: const ColorScheme.dark(
          primary: AppColors.white,
          onPrimary: AppColors.black,
          surface: AppColors.black,
          onSurface: AppColors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
