import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/core/utils/haptic_utils.dart';

enum AppButtonState { idle, loading, disabled, success }

class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = AppButtonState.idle,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonState state;
  final double? width;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  bool get _isDisabled =>
      widget.state == AppButtonState.disabled ||
      widget.state == AppButtonState.loading ||
      widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.state == AppButtonState.success;
    final isLoading = widget.state == AppButtonState.loading;

    return AnimatedScale(
      scale: _pressed && !_isDisabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width ?? double.infinity,
        height: 50,
        child: Material(
          color: _isDisabled
              ? AppColors.textSecondary.withValues(alpha: 0.3)
              : isSuccess
                  ? AppColors.success
                  : AppColors.accent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            onTap: _isDisabled
                ? null
                : () async {
                    await HapticUtils.light();
                    widget.onPressed?.call();
                  },
            onTapDown: _isDisabled ? null : (_) => setState(() => _pressed = true),
            onTapUp: _isDisabled ? null : (_) => setState(() => _pressed = false),
            onTapCancel: _isDisabled ? null : () => setState(() => _pressed = false),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Row(
                        key: ValueKey(widget.label),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSuccess) ...[
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.background,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            widget.label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
