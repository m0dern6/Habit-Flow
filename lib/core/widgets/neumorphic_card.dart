import 'package:flutter/material.dart';
import '../theme/neumorphism_style.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? color;
  final double depth;
  final bool isInverted;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.color,
    this.depth = 8,
    this.isInverted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = Container(
      padding: padding,
      margin: margin,
      decoration: isDark
          ? NeumorphismStyle.createDarkNeumorphism(
              color: color,
              depth: depth.abs(),
              isInverted: isInverted,
              borderRadius: borderRadius,
            )
          : NeumorphismStyle.createNeumorphism(
              color: color,
              depth: depth.abs(),
              isInverted: isInverted,
              borderRadius: borderRadius,
            ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
