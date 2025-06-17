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
import '../../core/widgets/glassmorphic_container.dart';
import '../../core/widgets/liquid_glass_container.dart' as custom_glass;
import '../quotes/favorite_quotes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isGeneratingQuote = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Charger une citation au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshQuote();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshQuote() async {
    if (_isGeneratingQuote) return;
    
    setState(() {
      _isGeneratingQuote = true;
    });
    
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    
    // Utiliser la dernière entrée d'humeur pour générer une citation adaptée
    final lastMoodEntry = moodProvider.entries.isNotEmpty 
        ? moodProvider.entries.last 
        : null;
    
    await quoteProvider.generateQuoteForMood(lastMoodEntry);
    
    if (mounted) {
      setState(() {
        _isGeneratingQuote = false;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'MoodSpace',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comment vous sentez-vous aujourd\'hui ?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Bouton pour accéder aux citations favorites
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                            const FavoriteQuotesScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    tooltip: 'Citations favorites',
                  ),
                ),
                
                // Citation inspirante
                Expanded(
                  child: Center(
                    child: Consumer<QuoteProvider>(
                      builder: (context, quoteProvider, child) {
                        final currentQuote = quoteProvider.currentQuote;
                        final isLoading = quoteProvider.isLoading || _isGeneratingQuote;
                        
                        return GestureDetector(
                          onTap: _refreshQuote,
                          child: custom_glass.LiquidGlassContainer(
                            width: size.width * 0.9,
                            height: size.height * 0.3,
                            borderRadius: BorderRadius.circular(20),
                            blur: 10,
                            opacity: 0.15,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : _buildQuoteWidget(currentQuote, theme),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Bouton pour ajouter une humeur
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 15,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const MoodEntryScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCubic;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Center(
                        child: Text(
                          'Noter mon humeur',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteWidget(Quote? quote, ThemeData theme) {
    if (quote == null) {
      return const Center(
        child: Text(
          'Aucune citation disponible',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: _animationController,
              child: Text(
                '"${quote.text}"',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: _animationController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '— ${quote.author}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<QuoteProvider>(
                    builder: (context, provider, _) {
                      final isFavorite = provider.isFavorite(quote);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red.shade300 : Colors.white70,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            provider.removeFromFavorites(quote);
                          } else {
                            provider.addToFavorites(quote);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez pour générer une nouvelle citation',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
} 