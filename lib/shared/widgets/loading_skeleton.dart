import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ShimmerPainter extends StatefulWidget {
  final Widget child;

  const ShimmerPainter({super.key, required this.child});

  @override
  State<ShimmerPainter> createState() => _ShimmerPainterState();
}

class _ShimmerPainterState extends State<ShimmerPainter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.cardBorder,
                AppColors.cardBorder,
                AppColors.inputFill,
                AppColors.cardBorder,
                AppColors.cardBorder,
              ],
              stops: [
                0.0,
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class FlightCardSkeleton extends StatelessWidget {
  const FlightCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerPainter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 100, height: 18),
                const SkeletonBox(width: 70, height: 22, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SkeletonBox(width: 40, height: 24),
                const SizedBox(width: 8),
                const SkeletonBox(width: 60, height: 2),
                const SizedBox(width: 8),
                const SkeletonBox(width: 40, height: 24),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SkeletonBox(width: 120, height: 14),
                const SizedBox(width: 16),
                const SkeletonBox(width: 80, height: 14),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SkeletonBox(width: 60, height: 12),
                    const SizedBox(width: 16),
                    const SkeletonBox(width: 40, height: 12),
                  ],
                ),
                const SkeletonBox(width: 50, height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TableRowSkeleton extends StatelessWidget {
  final int columns;

  const TableRowSkeleton({super.key, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerPainter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: List.generate(
            columns,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < columns - 1 ? 12 : 0),
                child: const SkeletonBox(height: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
