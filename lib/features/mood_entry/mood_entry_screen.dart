import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/mood_entry.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/providers/quote_provider.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_container.dart';
import 'mood_slider.dart';
import '../home/home_screen.dart';

class MoodEntryScreen extends StatefulWidget {
  final MoodEntry? editEntry;

  const MoodEntryScreen({
    super.key,
    this.editEntry,
  });

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  double _moodValue = 0.5;
  File? _imageFile;
  final List<String> _selectedTags = [];
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  bool _isSaving = false;
  
  // Liste de tags prédéfinis
  final List<String> _availableTags = [
    'Travail', 'Famille', 'Amis', 'Sport', 'Santé', 
    'Relaxation', 'Stress', 'Sommeil', 'Alimentation', 'Loisirs'
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Animation pour l'effet de flou
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _blurAnimation = Tween<double>(begin: 40.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCirc,
      ),
    );
    
    _animationController.forward();
    
    // Si on édite une entrée existante, initialiser les valeurs
    if (widget.editEntry != null) {
      _moodValue = widget.editEntry!.moodScore;
      _noteController.text = widget.editEntry!.note ?? '';
      _selectedTags.addAll(widget.editEntry!.tags);
      
      // Charger l'image si elle existe
      if (widget.editEntry!.imagePath != null) {
        _imageFile = File(widget.editEntry!.imagePath!);
      }
    }
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Méthode pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  // Méthode pour prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  // Méthode pour supprimer l'image sélectionnée
  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }
  
  // Méthode pour basculer la sélection d'un tag
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }
  
  // Méthode pour sauvegarder l'entrée d'humeur
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      
      final entry = MoodEntry(
        id: widget.editEntry?.id ?? const Uuid().v4(),
        date: DateTime.now(),
        moodScore: _moodValue,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        imagePath: _imageFile?.path,
        tags: _selectedTags,
      );
      
      if (widget.editEntry != null) {
        await moodProvider.updateEntry(entry);
      } else {
        await moodProvider.addEntry(entry);
      }
      
      // Générer une citation inspirante adaptée à l'humeur
      await quoteProvider.generateQuoteForMood(entry);
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        // Retourner à l'écran d'accueil
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.editEntry != null 
            ? 'Modifier l\'entrée' 
            : 'Nouvelle entrée'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _saveEntry,
                  icon: const Icon(Icons.check),
                  tooltip: 'Enregistrer',
                ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Cercles décoratifs en arrière-plan
            _buildBackgroundCircles(),
            
            // Effet de flou sur l'arrière-plan
            AnimatedBuilder(
              animation: _blurAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                );
              },
            ),
            
            // Contenu principal
            SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  children: [
                    // Sélecteur d'humeur
                    LiquidGlassContainer(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comment vous sentez-vous ?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          MoodSlider(
                            initialValue: _moodValue,
                            onChanged: (value) {
                              setState(() {
                                _moodValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMedium),
                    
                    // Champ de texte pour les notes
                    LiquidGlassContainer(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Décrivez votre journée, vos émotions...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMedium),
                    
                    // Sélection d'image
                    LiquidGlassContainer(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter une image',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          if (_imageFile != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),
                            Center(
                              child: TextButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                label: Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GlassButton(
                                  onPressed: _pickImage,
                                  useLiquidEffect: true,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.photo_library, color: Colors.white),
                                      const SizedBox(width: AppTheme.spacingSmall),
                                      const Text('Galerie', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                GlassButton(
                                  onPressed: _takePhoto,
                                  useLiquidEffect: true,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.camera_alt, color: Colors.white),
                                      const SizedBox(width: AppTheme.spacingSmall),
                                      const Text('Caméra', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMedium),
                    
                    // Tags
                    LiquidGlassContainer(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          Wrap(
                            spacing: AppTheme.spacingSmall,
                            runSpacing: AppTheme.spacingSmall,
                            children: _availableTags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return FilterChip(
                                selected: isSelected,
                                label: Text(tag),
                                onSelected: (_) => _toggleTag(tag),
                                backgroundColor: Colors.white.withOpacity(0.1),
                                selectedColor: AppTheme.primaryColor.withOpacity(0.7),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.5) 
                                        : Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackgroundCircles() {
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
  }
} 