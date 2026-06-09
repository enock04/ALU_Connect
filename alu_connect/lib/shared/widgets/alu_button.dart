import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

enum ALUButtonVariant { primary, secondary, ghost }

class ALUButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ALUButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final double? width;
  final double height;

  const ALUButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ALUButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final btn = switch (variant) {
      ALUButtonVariant.primary => ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: content,
        ),
      ALUButtonVariant.secondary => OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: content,
        ),
      ALUButtonVariant.ghost => TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: ALUColors.textSecondary,
            minimumSize: Size(width ?? double.infinity, height),
          ),
          child: content,
        ),
    };

    return SizedBox(width: width ?? double.infinity, height: height, child: btn);
  }
}
