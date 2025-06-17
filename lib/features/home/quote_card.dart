import 'package:flutter/material.dart';
import '../../core/models/quote.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_container.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onRefresh;
  final bool useLiquidEffect;
  
  const QuoteCard({
    super.key,
    required this.quote,
    this.onRefresh,
    this.useLiquidEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return useLiquidEffect 
      ? LiquidGlassContainer(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: _buildQuoteContent(context),
        )
      : GlassCard(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: _buildQuoteContent(context),
        );
  }
  
  Widget _buildQuoteContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: Colors.white70,
              size: 28,
            ),
            const Spacer(),
            if (onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white70,
                ),
                tooltip: 'Nouvelle citation',
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing),
        Text(
          quote.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '— ${quote.author}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

// Animation pour faire apparaître la citation
class AnimatedQuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onRefresh;
  final Duration duration;
  final bool useLiquidEffect;
  
  const AnimatedQuoteCard({
    super.key,
    required this.quote,
    this.onRefresh,
    this.duration = const Duration(milliseconds: 800),
    this.useLiquidEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: QuoteCard(
        quote: quote,
        onRefresh: onRefresh,
        useLiquidEffect: useLiquidEffect,
      ),
    );
  }
} 