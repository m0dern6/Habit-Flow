import 'package:flutter/material.dart';
import '../theme/neumorphism_style.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final double depth;
  final bool isEnabled;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.color,
    this.depth = 8,
    this.isEnabled = true,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: widget.padding,
              decoration: _isPressed
                  ? (isDark
                      ? NeumorphismStyle.createDarkNeumorphism(
                          color: widget.color,
                          depth: widget.depth.abs(),
                          isPressed: true,
                          borderRadius: widget.borderRadius,
                        )
                      : NeumorphismStyle.createPressedNeumorphism(
                          color: widget.color,
                          depth: widget.depth.abs(),
                          borderRadius: widget.borderRadius,
                        ))
                  : (isDark
                      ? NeumorphismStyle.createDarkNeumorphism(
                          color: widget.color,
                          depth: widget.depth.abs(),
                          borderRadius: widget.borderRadius,
                        )
                      : NeumorphismStyle.createNeumorphism(
                          color: widget.color,
                          depth: widget.depth.abs(),
                          borderRadius: widget.borderRadius,
                        )),
              child: Opacity(
                opacity: widget.isEnabled ? 1.0 : 0.6,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
