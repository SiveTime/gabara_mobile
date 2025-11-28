import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String label;
  final Function? onPressed;
  final bool isPrimary;
  final double borderRadius;

  const CommonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBlue : accentOrange,
          foregroundColor: appWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed != null ? () => onPressed!() : null,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
