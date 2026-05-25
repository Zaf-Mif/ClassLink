import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: const Center(
        child: Text(
          'Search\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppColors.textGrey, fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
