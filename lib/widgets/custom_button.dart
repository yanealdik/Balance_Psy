import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Кастомная кнопка с различными вариантами дизайна
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary; // true - синяя кнопка, false - белая кнопка
  final bool isOutlined; // true - обводка без заливки
  final IconData? icon; // Иконка для кнопки (слева от текста)
  final bool showArrow; // Показывать стрелку справа
  final bool isFullWidth; // Растянуть на всю ширину
  final double? height; // Высота кнопки (по умолчанию 56)
  final double? fontSize; // Размер шрифта (по умолчанию 16)
  final bool isLoading; // Показывать индикатор загрузки

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.showArrow = false,
    this.isFullWidth = false,
    this.height,
    this.fontSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular((height ?? 56) / 2),
        border: isOutlined
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: isPrimary && !isOutlined && onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular((height ?? 56) / 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                    ),
                  ),
                ] else ...[
                  if (icon != null) ...[
                    Icon(icon, color: _getTextColor(), size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: (isPrimary
                            ? AppTextStyles.button
                            : AppTextStyles.buttonSecondary)
                        .copyWith(
                          fontSize: fontSize ?? 16,
                          color: _getTextColor(),
                        ),
                  ),
                  if (showArrow) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: _getTextColor(), size: 20),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return buttonContent;
  }

  // Определяем цвет фона кнопки
  Color _getBackgroundColor() {
    if (onPressed == null || isLoading) {
      // Disabled state
      return AppColors.inputBorder;
    }
    if (isOutlined) return Colors.transparent;
    return isPrimary ? AppColors.primary : AppColors.background;
  }

  // Определяем цвет текста кнопки
  Color _getTextColor() {
    if (onPressed == null || isLoading) {
      // Disabled state
      return AppColors.textTertiary;
    }
    if (isOutlined) return AppColors.primary;
    return isPrimary ? AppColors.textWhite : AppColors.primary;
  }
}
