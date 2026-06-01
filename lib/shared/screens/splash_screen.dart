import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/airplane_silhouette.svg',
              width: 80,
              colorFilter: const ColorFilter.mode(
                AppColors.cyan,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AEROPUERTO',
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.cyan,
                letterSpacing: 4,
              ),
            ),
            Text(
              'MGT',
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.cyan,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
