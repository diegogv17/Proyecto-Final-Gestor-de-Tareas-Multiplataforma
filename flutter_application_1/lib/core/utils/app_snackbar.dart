import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? AppColors.danger
        : isSuccess
            ? AppColors.success
            : AppColors.textSecondary;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : isSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.info_outline_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
  }
}
