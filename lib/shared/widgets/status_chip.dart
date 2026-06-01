import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  const StatusChip.green(this.label, {super.key}) : color = AppColors.chipGreen;
  const StatusChip.yellow(this.label, {super.key}) : color = AppColors.chipYellow;
  const StatusChip.red(this.label, {super.key}) : color = AppColors.chipRed;
  const StatusChip.purple(this.label, {super.key}) : color = AppColors.chipPurple;
  const StatusChip.cyan(this.label, {super.key}) : color = AppColors.cyan;
  const StatusChip.orange(this.label, {super.key}) : color = AppColors.orange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  static Color colorForStatus(String status) {
    switch (status) {
      case 'scheduled':
        return AppColors.cyan;
      case 'boarding':
        return AppColors.chipGreen;
      case 'departed':
        return AppColors.chipYellow;
      case 'arrived':
        return AppColors.chipGreen;
      case 'delayed':
        return AppColors.orange;
      case 'cancelled':
        return AppColors.chipRed;
      default:
        return AppColors.gray;
    }
  }

  static String labelForStatus(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programado';
      case 'boarding':
        return 'Abordando';
      case 'departed':
        return 'Salió';
      case 'arrived':
        return 'Llegó';
      case 'delayed':
        return 'Retrasado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
