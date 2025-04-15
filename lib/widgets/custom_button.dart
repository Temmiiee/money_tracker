import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool isOutlined;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isOutlined = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    Widget buttonWidget;

    if (isOutlined) {
      buttonWidget = OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.m,
            horizontal: AppSizes.l,
          ),
          foregroundColor: buttonColor,
        ),
        child: _buildButtonContent(buttonColor),
      );
    } else {
      buttonWidget = ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withAlpha(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.m,
            horizontal: AppSizes.l,
          ),
        ),
        child: _buildButtonContent(Colors.white),
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildButtonContent(Color textColor) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: AppSizes.s),
          Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(color: textColor),
    );
  }
}
