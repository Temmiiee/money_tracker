import 'package:flutter/material.dart';
import 'constants.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    this.size = 48.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(size: size),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            AppTexts.appName,
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
