import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TodoFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const TodoFlowLogo({
    super.key,
    this.size = 40,
    this.showText = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _TodoFlowLogoPainter(),
      ),
    );

    if (!showText) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TodoFlow',
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.1,
              ),
            ),
            Text(
              'Tasks',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodoFlowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;

    // Checkmark: M28 52L42 66L72 36 (Stroke #FFFFFF, width 9)
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 9.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(28 * scale, 52 * scale);
    checkPath.lineTo(42 * scale, 66 * scale);
    checkPath.lineTo(72 * scale, 36 * scale);
    canvas.drawPath(checkPath, checkPaint);

    // Flow stroke: M38 74C46 80 58 80 66 74 (Stroke #0D9488, width 5)
    final flowPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 5.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final flowPath = Path();
    flowPath.moveTo(38 * scale, 74 * scale);
    flowPath.cubicTo(
      46 * scale, 80 * scale,
      58 * scale, 80 * scale,
      66 * scale, 74 * scale,
    );
    canvas.drawPath(flowPath, flowPaint);

    // Sparkle circle: cx=76, cy=30, r=5 (Fill #0D9488)
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(76 * scale, 30 * scale), 5 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
