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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _blurAnimation = Tween<double>(begin: 50.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCirc,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _HomeContent(blurAnimation: _blurAnimation),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Animation<double> blurAnimation;
  
  const _HomeContent({required this.blurAnimation});
  
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
          // Cercles décoratifs en arrière-plan avec animation
          _buildAnimatedBackgroundCircles(),
          
          // Effet de flou sur l'arrière-plan
          AnimatedBuilder(
            animation: blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAnimation.value,
                  sigmaY: blurAnimation.value,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              );
            },
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
                  
                  // Citation du jour avec effet liquid glass
                  AnimatedQuoteCard(
                    quote: quote,
                    onRefresh: () => quoteProvider.getNewRandomQuote(),
                    useLiquidEffect: true,
                  ),
                  
                  const Spacer(),
                  
                  // Bouton pour ajouter une humeur
                  Center(
                    child: LiquidGlassContainer(
                      borderRadius: AppTheme.buttonRadius,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXLarge,
                        vertical: AppTheme.spacingMedium,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                const MoodEntryScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var curve = Curves.easeInOut;
                                var curveTween = CurveTween(curve: curve);
                                
                                var fadeAnimation = Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(
                                  animation.drive(curveTween),
                                );
                                
                                var scaleAnimation = Tween<double>(
                                  begin: 0.95,
                                  end: 1.0,
                                ).animate(
                                  animation.drive(curveTween),
                                );
                                
                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: ScaleTransition(
                                    scale: scaleAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
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
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Statistiques ou résumé (optionnel)
                  if (!moodProvider.isLoading && moodProvider.entries.isNotEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      useLiquidEffect: true,
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
  
  Widget _buildAnimatedBackgroundCircles() {
    return AnimatedBuilder(
      animation: blurAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Cercle principal
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.3),
                      AppTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Cercle secondaire
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryColor.withOpacity(0.25),
                      AppTheme.secondaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Cercle accent
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.2),
                      AppTheme.accentColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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