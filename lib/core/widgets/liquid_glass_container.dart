import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Alignment? alignment;
  final bool enableShimmer;
  final Duration shimmerDuration;

  const LiquidGlassContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.blur = 10,
    this.opacity = 0.2,
    required this.child,
    this.padding,
    this.alignment,
    this.enableShimmer = false,
    this.shimmerDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Effet de verre de base
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity / 2),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            
            // Effet de reflet liquide
            if (enableShimmer)
              _buildShimmerEffect(),
            
            // Contenu
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Align(
                alignment: alignment ?? Alignment.center,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -1.0, end: 1.0),
      duration: shimmerDuration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                (value + 1) / 2 - 0.1,
                (value + 1) / 2,
                (value + 1) / 2 + 0.1,
                1.0,
              ],
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.white.withOpacity(0.2),
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
} 