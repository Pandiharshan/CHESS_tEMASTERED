import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(const ChessRemasteredApp());
}

class ChessRemasteredApp extends StatelessWidget {
  const ChessRemasteredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MaterialApp(
        title: 'Chess Remastered',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
