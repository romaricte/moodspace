import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final double border;
  final Alignment? alignment;
  final Widget child;
  final LinearGradient linearGradient;
  final LinearGradient borderGradient;

  const GlassmorphicContainer({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.blur = 10,
    this.border = 1,
    this.alignment,
    required this.child,
    required this.linearGradient,
    required this.borderGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: linearGradient,
        ),
        child: Stack(
          children: [
            // Effet de flou
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: border,
                  ),
                  gradient: linearGradient,
                ),
              ),
            ),
            
            // Bordure avec dégradé
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  width: border,
                ),
                gradient: borderGradient,
              ),
            ),
            
            // Contenu
            Align(
              alignment: alignment ?? Alignment.center,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
} 