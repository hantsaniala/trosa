import 'package:flutter/material.dart';
import 'package:trosa/theme.dart';

/// The Trosa brand mark: a rounded brand-yellow square with the dark
/// double-headed arrow (money to receive / money to pay).
///
/// Draws the same geometry as the launcher icon in
/// `tool/generate_icon.dart` (same palette, same proportions) so the mark is
/// pixel-identical at any size without shipping a heavy PNG asset.
class TrosaMark extends StatelessWidget {
  final double size;

  const TrosaMark({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _TrosaMarkPainter(),
    );
  }
}

class _TrosaMarkPainter extends CustomPainter {
  const _TrosaMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 1024;

    // Brand-yellow rounded square (radius matches the launcher icon).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(210 * scale),
      ),
      Paint()..color = AppTheme.brand,
    );

    // Double-headed arrow — constants and layout mirror the launcher icon in
    // tool/generate_icon.dart (1024 canvas, center 512, y = -x + 1024 axis).
    const double d = 0.7071067811865476; // sqrt(2) / 2
    const double halfExtent = 240; // head-tip half extent from center
    const double headLen = 185;
    const double baseHalf = 80;
    const double shaftR = 66;

    // Unscaled (1024-space) geometry.
    final tNeX = 512 + halfExtent, tNeY = 512 - halfExtent;
    final bNeX = tNeX - headLen * d, bNeY = tNeY + headLen * d;
    final c1NeX = bNeX - baseHalf * d, c1NeY = bNeY - baseHalf * d;
    final c2NeX = bNeX + baseHalf * d, c2NeY = bNeY + baseHalf * d;
    final tSwX = 512 - halfExtent, tSwY = 512 + halfExtent;
    final bSwX = tSwX + headLen * d, bSwY = tSwY - headLen * d;
    final c1SwX = bSwX - baseHalf * d, c1SwY = bSwY - baseHalf * d;
    final c2SwX = bSwX + baseHalf * d, c2SwY = bSwY + baseHalf * d;

    Offset p(double x, double y) => Offset(x * scale, y * scale);

    final baseNe = p(bNeX, bNeY);
    final baseSw = p(bSwX, bSwY);
    final tipNe = p(tNeX, tNeY);
    final c1Ne = p(c1NeX, c1NeY);
    final c2Ne = p(c2NeX, c2NeY);
    final tipSw = p(tSwX, tSwY);
    final c1Sw = p(c1SwX, c1SwY);
    final c2Sw = p(c2SwX, c2SwY);

    final ink = Paint()..color = AppTheme.ink;

    // Shaft with round caps (covers the head base seams, like the icon).
    canvas.drawPath(
      Path()..moveTo(baseNe.dx, baseNe.dy)..lineTo(baseSw.dx, baseSw.dy),
      Paint()
        ..color = AppTheme.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * shaftR * scale
        ..strokeCap = StrokeCap.round,
    );

    // Arrowheads.
    final triNe = Path()
      ..moveTo(tipNe.dx, tipNe.dy)
      ..lineTo(c1Ne.dx, c1Ne.dy)
      ..lineTo(c2Ne.dx, c2Ne.dy)
      ..close();
    final triSw = Path()
      ..moveTo(tipSw.dx, tipSw.dy)
      ..lineTo(c1Sw.dx, c1Sw.dy)
      ..lineTo(c2Sw.dx, c2Sw.dy)
      ..close();
    canvas.drawPath(triNe, ink);
    canvas.drawPath(triSw, ink);
  }

  @override
  bool shouldRepaint(covariant _TrosaMarkPainter oldDelegate) => false;
}
