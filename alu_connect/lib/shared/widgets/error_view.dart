import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'alu_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: ALUColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: ALUColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ALUButton(label: 'Try again', onPressed: onRetry, width: 180, height: 44),
            ],
          ],
        ),
      ),
    );
  }
}

// inline error for forms / cards
class InlineError extends StatelessWidget {
  final String message;
  const InlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ALUColors.redDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ALUColors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: ALUColors.redLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: ALUColors.redLight, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
