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
  final bool useAdvancedBlur;
  final bool useLiquidEffect;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.borderRadius,
    this.blur = 15.0,
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
    this.useAdvancedBlur = true,
    this.useLiquidEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!useAdvancedBlur) {
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

    return Container(
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(useLiquidEffect ? 0.35 : 0.25),
                  Colors.white.withOpacity(useLiquidEffect ? 0.15 : 0.1),
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor.withOpacity(0.5),
                width: borderWidth,
              ),
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
  final bool useLiquidEffect;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.margin = const EdgeInsets.all(AppTheme.spacing),
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = AppTheme.borderRadius,
    this.useLiquidEffect = false,
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
      useLiquidEffect: useLiquidEffect,
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
  final bool useLiquidEffect;
  
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
    this.blur = 10.0,
    this.color = AppTheme.glassColor,
    this.useLiquidEffect = true,
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
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        useLiquidEffect: useLiquidEffect,
        child: child,
      ),
    );
  }
}

// Widget pour créer un effet de verre liquide (style iOS 26)
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Color? glowColor;
  
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppTheme.primaryColor;
    
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.15),
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
} 