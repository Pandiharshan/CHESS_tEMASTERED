import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    color: AppColors.text,
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: 8.0,
    fontFamily: 'Courier', 
  );

  static const TextStyle buttonText = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    fontFamily: 'Courier',
  );
}
