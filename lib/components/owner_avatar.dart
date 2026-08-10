import 'package:flutter/material.dart';

/// Deterministic, name-based colors for debt owners so each person gets a
/// stable, scannable color everywhere (cards, stats, dialogs).
Color ownerColor(String owner) {
  const palette = <Color>[
    Color(0xFF2E7D32), // green
    Color(0xFF1565C0), // blue
    Color(0xFF6A1B9A), // purple
    Color(0xFFC62828), // red
    Color(0xFF00695C), // teal
    Color(0xFFEF6C00), // orange
    Color(0xFF4527A0), // deep purple
    Color(0xFF2E5090), // indigo
    Color(0xFF8E24AA), // magenta
    Color(0xFF3E8E41), // green-ish
    Color(0xFFD81B60), // pink
    Color(0xFF0277BD), // light blue
  ];
  if (owner.trim().isEmpty) return const Color(0xFF757575);
  var hash = 0;
  for (final code in owner.trim().codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

/// Circular avatar with the owner's initial on a stable per-person color.
class OwnerAvatar extends StatelessWidget {
  final String owner;
  final double size;
  final double fontSize;

  const OwnerAvatar({
    super.key,
    required this.owner,
    this.size = 40,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final initial = owner.trim().isEmpty
        ? '?'
        : owner.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ownerColor(owner).withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: ownerColor(owner).withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: ownerColor(owner),
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
