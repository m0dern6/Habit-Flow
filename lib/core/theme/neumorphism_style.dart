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
    final baseColor = color ?? AppColors.background;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final safeDepth = depth.abs(); // Ensure depth is always positive

    if (isPressed) {
      return BoxDecoration(
        color: baseColor.withOpacity(0.95),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDarkest.withOpacity(0.4),
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
            color: AppColors.shadowLight.withOpacity(0.7),
            offset: Offset(-safeDepth, -safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
          BoxShadow(
            color: AppColors.shadowDarkest.withOpacity(0.3),
            offset: Offset(safeDepth, safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDarkest.withOpacity(0.2),
          offset: Offset(safeDepth, safeDepth),
          blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
        ),
        BoxShadow(
          color: AppColors.shadowLight.withOpacity(0.9),
          offset: Offset(-safeDepth, -safeDepth),
          blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
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
        color: baseColor.withOpacity(0.95),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDarkDark.withOpacity(0.6),
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
            color: AppColors.shadowLightDark.withOpacity(0.1),
            offset: Offset(-safeDepth, -safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
          BoxShadow(
            color: AppColors.shadowDarkDark.withOpacity(0.5),
            offset: Offset(safeDepth, safeDepth),
            blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDarkDark.withOpacity(0.3),
          offset: Offset(safeDepth, safeDepth),
          blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
        ),
        BoxShadow(
          color: AppColors.shadowLightDark.withOpacity(0.1),
          offset: Offset(-safeDepth, -safeDepth),
          blurRadius: (safeDepth * 2).clamp(0.0, double.infinity),
        ),
      ],
    );
  }
}
