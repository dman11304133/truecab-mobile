import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/styles.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? blur;
  final Color? color;
  final Color? borderColor;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;

  const GlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.blur,
    this.color,
    this.borderColor,
    this.shape = BoxShape.rectangle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: shape == BoxShape.circle ? BorderRadius.circular(1000) : (borderRadius ?? BorderRadius.circular(20)),
      child: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur ?? glassBlur,
                sigmaY: blur ?? glassBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                   color: Colors.transparent,
                   shape: shape,
                ),
              ),
            ),
            // Gradient / Tint / Border
            Container(
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(20)),
                border: Border.all(
                  color: borderColor ?? glassBorderColor,
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (color ?? glassColor).withOpacity(0.15),
                    (color ?? glassColor).withOpacity(0.05),
                  ],
                ),
              ),
            ),
            // Content
            child,
          ],
        ),
      ),
    );
  }
}
