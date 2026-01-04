import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphismStyle {
  static BoxDecoration createNeumorphism({
    Color? color,
    double depth = 8,
    bool isPressed = false,
    bool isInverted = false,
    BorderRadius? borderRadius,
  }) {
    final baseColor = color ?? AppColors.surface;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final safeDepth = depth.abs(); // Ensure depth is always positive

    if (isPressed) {
      return BoxDecoration(
        color: baseColor.withAlpha((255 * 0.95).round()),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDarkest.withAlpha((255 * 0.55).round()),
            offset: Offset(safeDepth / 4, safeDepth / 4),
            blurRadius: (safeDepth / 2).clamp(0.0, double.infinity),
            spreadRadius: -(safeDepth / 4),
          ),
        ],
      );
    }

    if (isInverted) {
      return BoxDecoration(
        color: baseColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withAlpha((255 * 0.7).round()),
            offset: Offset(-safeDepth, -safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
          BoxShadow(
            color: AppColors.shadowDarkest.withAlpha((255 * 0.45).round()),
            offset: Offset(safeDepth, safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: radius,
      border: Border.all(
        color: AppColors.shadowDarkest.withAlpha(25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDarkest
              .withAlpha(170), // Darker shadow for stronger depth
          offset: Offset(safeDepth * 1.8, safeDepth * 1.8),
          blurRadius: safeDepth * 5.25,
          spreadRadius: 2.0,
        ),
        BoxShadow(
          color: AppColors.shadowLight.withAlpha(250), // Maximum brightness
          offset: Offset(-safeDepth * 1.8, -safeDepth * 1.8),
          blurRadius: safeDepth * 5.25,
          spreadRadius: 2.0,
        ),
      ],
    );
  }

  static BoxDecoration createFlatNeumorphism({
    Color? color,
    double depth = 4,
    BorderRadius? borderRadius,
  }) {
    return createNeumorphism(
      color: color,
      depth: depth,
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration createRaisedNeumorphism({
    Color? color,
    double depth = 12,
    BorderRadius? borderRadius,
  }) {
    return createNeumorphism(
      color: color,
      depth: depth,
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration createPressedNeumorphism({
    Color? color,
    double depth = 8,
    BorderRadius? borderRadius,
  }) {
    return createNeumorphism(
      color: color,
      depth: depth,
      isPressed: true,
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration createInvertedNeumorphism({
    Color? color,
    double depth = 8,
    BorderRadius? borderRadius,
  }) {
    return createNeumorphism(
      color: color,
      depth: depth,
      isInverted: true,
      borderRadius: borderRadius,
    );
  }

  // Dark theme neumorphism
  static BoxDecoration createDarkNeumorphism({
    Color? color,
    double depth = 8,
    bool isPressed = false,
    bool isInverted = false,
    BorderRadius? borderRadius,
  }) {
    final baseColor = color ?? AppColors.surfaceDark;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final safeDepth = depth.abs(); // Ensure depth is always positive

    if (isPressed) {
      return BoxDecoration(
        color: baseColor.withAlpha((255 * 0.95).round()),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDarkDark.withAlpha((255 * 0.75).round()),
            offset: Offset(safeDepth / 4, safeDepth / 4),
            blurRadius: (safeDepth / 2).clamp(0.0, double.infinity),
            spreadRadius: -(safeDepth / 4),
          ),
        ],
      );
    }

    if (isInverted) {
      return BoxDecoration(
        color: baseColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLightDark.withAlpha((255 * 0.1).round()),
            offset: Offset(-safeDepth, -safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
          BoxShadow(
            color: AppColors.shadowDarkDark.withAlpha((255 * 0.65).round()),
            offset: Offset(safeDepth, safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: radius,
      border: Border.all(
        color: AppColors.shadowLightDark.withAlpha(35),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDarkDark
              .withAlpha(255), // Maximum opacity for strongest separation
          offset: Offset(safeDepth * 1.2, safeDepth * 1.2),
          blurRadius: safeDepth * 3.5,
          spreadRadius: 2.0,
        ),
        BoxShadow(
          color: AppColors.shadowLightDark.withAlpha(80), // Stronger light edge
          offset: Offset(-safeDepth * 1.2, -safeDepth * 1.2),
          blurRadius: safeDepth * 3.5,
          spreadRadius: 2.0,
        ),
      ],
    );
  }
}
