import 'package:flutter/material.dart';

class InfoLabel extends StatelessWidget {
  const InfoLabel({
    required this.label,
    this.color,
    this.fontWeight = FontWeight.w700,
    super.key,
  });

  final String label;
  final Color? color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: effectiveColor,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
