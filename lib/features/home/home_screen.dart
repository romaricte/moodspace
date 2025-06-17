import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/quote.dart';
import '../../core/providers/quote_provider.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_container.dart';
import 'quote_card.dart';
import '../mood_entry/mood_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final quote = quoteProvider.dailyQuote ?? 
        Quote(text: "Bienvenue dans MoodSpace", author: "Votre journal de bien-être");
    
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Cercles décoratifs en arrière-plan
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withOpacity(0.15),
              ),
            ),
          ),
          
          // Effet de flou sur l'arrière-plan
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          
          // Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  const SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    'MoodSpace',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Comment vous sentez-vous aujourd\'hui ?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXLarge),
                  
                  // Citation du jour
                  AnimatedQuoteCard(
                    quote: quote,
                    onRefresh: () => quoteProvider.getNewRandomQuote(),
                  ),
                  
                  const Spacer(),
                  
                  // Bouton pour ajouter une humeur
                  Center(
                    child: GlassButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodEntryScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXLarge,
                        vertical: AppTheme.spacingMedium,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_reaction_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.spacingMedium),
                          Text(
                            'Noter mon humeur',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Statistiques ou résumé (optionnel)
                  if (!moodProvider.isLoading && moodProvider.entries.isNotEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.calendar_today,
                            value: moodProvider.entries.length.toString(),
                            label: 'Entrées',
                          ),
                          _StatItem(
                            icon: Icons.trending_up,
                            value: (moodProvider.getAverageMoodForDateRange(
                              DateTime.now().subtract(const Duration(days: 7)),
                              DateTime.now(),
                            ) * 100).toStringAsFixed(0) + '%',
                            label: 'Moy. 7j',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
} 