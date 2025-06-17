import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final List<BoxShadow>? boxShadow;
  final Alignment? alignment;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.borderRadius,
    this.blur = 10.0,
    this.color = AppTheme.glassColor,
    this.borderColor = AppTheme.glassBorderColor,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: boxShadow,
            ),
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Widget pour créer une carte avec effet glassmorphism
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double borderRadius;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.margin = const EdgeInsets.all(AppTheme.spacing),
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = AppTheme.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final container = GlassContainer(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      boxShadow: AppTheme.cardShadow,
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }
    
    return container;
  }
}

// Bouton avec effet glassmorphism
class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blur;
  final Color color;
  
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingLarge,
      vertical: AppTheme.spacingMedium,
    ),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppTheme.buttonRadius,
    this.blur = 5.0,
    this.color = AppTheme.glassColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        padding: padding,
        margin: margin,
        borderRadius: borderRadius,
        blur: blur,
        color: color,
        boxShadow: AppTheme.cardShadow,
        child: child,
      ),
    );
  }
} 