import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SeatMapWidget extends StatefulWidget {
  final Set<String> occupiedSeats;
  final String? selectedSeat;
  final ValueChanged<String?> onSeatSelected;

  const SeatMapWidget({
    super.key,
    this.occupiedSeats = const {},
    this.selectedSeat,
    required this.onSeatSelected,
  });

  @override
  State<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> {
  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _firstClassMax = 4;
  static const _totalSeats = 30;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCockpit(),
        const SizedBox(height: 16),
        ...List.generate(_totalSeats, (rowIndex) {
          final rowNum = rowIndex + 1;
          return _buildSeatRow(rowNum);
        }),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildCockpit() {
    return Center(
      child: Container(
        width: 60,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.cardBorder.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: const Center(
          child: Text(
            'COCKPIT',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.gray,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatRow(int rowNum) {
    final isFirstClass = rowNum <= _firstClassMax;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              rowNum.toString(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.gray,
              ),
            ),
          ),
          const SizedBox(width: 4),
          ..._rows.map((col) {
            final seatId = '$rowNum$col';
            final isOccupied = widget.occupiedSeats.contains(seatId);
            final isSelected = widget.selectedSeat == seatId;
            return _SeatCell(
              seatId: seatId,
              isOccupied: isOccupied,
              isSelected: isSelected,
              isFirstClass: isFirstClass,
              onTap: () {
                if (!isOccupied) {
                  widget.onSeatSelected(isSelected ? null : seatId);
                }
              },
            );
          }),
          const SizedBox(width: 4),
          SizedBox(
            width: 24,
            child: Text(
              rowNum.toString(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.gray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(AppColors.inputFill, 'Disponible'),
        const SizedBox(width: 16),
        _legendItem(AppColors.cyan, 'Seleccionado'),
        const SizedBox(width: 16),
        _legendItem(AppColors.chipRed, 'Ocupado'),
        const SizedBox(width: 16),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.chipYellow, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const SizedBox(),
        ),
        const SizedBox(width: 4),
        const Text(
          '1ra Clase',
          style: TextStyle(fontSize: 10, color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: color == AppColors.inputFill ? 1.0 : 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color == AppColors.inputFill ? AppColors.inputBorder : color,
              width: color == AppColors.cyan ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.gray),
        ),
      ],
    );
  }
}

class _SeatCell extends StatelessWidget {
  final String seatId;
  final bool isOccupied;
  final bool isSelected;
  final bool isFirstClass;
  final VoidCallback onTap;

  const _SeatCell({
    required this.seatId,
    required this.isOccupied,
    required this.isSelected,
    required this.isFirstClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: isOccupied ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan.withValues(alpha: 0.2)
                : isOccupied
                    ? const Color(0xFF2A0A0A)
                    : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppColors.cyan
                  : isOccupied
                      ? AppColors.chipRed.withValues(alpha: 0.3)
                      : isFirstClass
                          ? AppColors.chipYellow
                          : AppColors.inputBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: isOccupied
                ? const Icon(Icons.person_off, size: 16, color: AppColors.chipRed)
                : isSelected
                    ? const Icon(Icons.check, size: 16, color: AppColors.cyan)
                    : Text(
                        seatId,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isFirstClass ? AppColors.chipYellow : AppColors.gray,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
