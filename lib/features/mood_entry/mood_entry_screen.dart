import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/mood_entry.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_container.dart';
import 'mood_slider.dart';

class MoodEntryScreen extends StatefulWidget {
  final MoodEntry? editEntry;

  const MoodEntryScreen({
    super.key,
    this.editEntry,
  });

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  double _moodValue = 0.5;
  File? _imageFile;
  final List<String> _selectedTags = [];
  
  // Liste de tags prédéfinis
  final List<String> _availableTags = [
    'Travail', 'Famille', 'Amis', 'Sport', 'Santé', 
    'Relaxation', 'Stress', 'Sommeil', 'Alimentation', 'Loisirs'
  ];
  
  @override
  void initState() {
    super.initState();
    
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
  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      
      final entry = MoodEntry(
        id: widget.editEntry?.id,
        date: DateTime.now(),
        moodScore: _moodValue,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        imagePath: _imageFile?.path,
        tags: _selectedTags,
      );
      
      if (widget.editEntry != null) {
        moodProvider.updateEntry(entry);
      } else {
        moodProvider.addEntry(entry);
      }
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editEntry != null 
            ? 'Modifier l\'entrée' 
            : 'Nouvelle entrée'),
        actions: [
          IconButton(
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
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              children: [
                // Sélecteur d'humeur
                GlassCard(
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
                GlassCard(
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
                GlassCard(
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
                GlassCard(
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
      ),
    );
  }
} 