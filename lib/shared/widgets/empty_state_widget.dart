import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? svgAsset;
  final IconData? iconData;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    this.svgAsset,
    this.iconData,
    required this.title,
    this.subtitle = '',
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: 96,
                colorFilter: const ColorFilter.mode(
                  AppColors.cyan,
                  BlendMode.srcIn,
                ),
              )
            else if (iconData != null)
              Icon(
                iconData,
                size: 72,
                color: AppColors.cyan.withValues(alpha: 0.3),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: AppColors.cyan),
                  foregroundColor: AppColors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
