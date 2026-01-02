import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool useGradient;

  const AppLogo({
    Key? key,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 12,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: useGradient ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/icons/app_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the original letter M if asset is missing or fails
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: const Text(
                'M',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
