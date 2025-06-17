import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';
import '../services/gemini_service.dart';
import '../models/mood_entry.dart';

class QuoteProvider extends ChangeNotifier {
  static const String _quotesStorageKey = 'quotes_storage';
  static const String _favoritesStorageKey = 'favorite_quotes';
  
  final GeminiService _geminiService;
  List<Quote> _quotes = [];
  List<Quote> _favoriteQuotes = [];
  Quote? _currentQuote;
  bool _isLoading = false;
  final Random _random = Random();
  DateTime? _lastQuoteDate;
  
  QuoteProvider({GeminiService? geminiService}) 
      : _geminiService = geminiService ?? GeminiService() {
    _loadQuotes();
  }
  
  List<Quote> get quotes => _quotes;
  List<Quote> get favoriteQuotes => _favoriteQuotes;
  Quote? get currentQuote => _currentQuote;
  Quote? get dailyQuote => _currentQuote;
  bool get isLoading => _isLoading;
  
  /// Charge les citations sauvegardées localement
  Future<void> _loadQuotes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Charger les citations générales
      final quotesJson = prefs.getStringList(_quotesStorageKey) ?? [];
      _quotes = quotesJson
          .map((json) => Quote.fromJson(jsonDecode(json)))
          .toList();
      
      // Charger les citations favorites
      final favoritesJson = prefs.getStringList(_favoritesStorageKey) ?? [];
      _favoriteQuotes = favoritesJson
          .map((json) => Quote.fromJson(jsonDecode(json)))
          .toList();
      
      // Définir la citation actuelle si disponible
      if (_quotes.isNotEmpty) {
        _currentQuote = _quotes.last;
      } else {
        // Ajouter quelques citations par défaut si aucune n'est disponible
        _addDefaultQuotes();
        _currentQuote = _quotes.last;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des citations: $e');
      // En cas d'erreur, utiliser des citations par défaut
      _addDefaultQuotes();
      _currentQuote = _quotes.last;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Ajoute des citations par défaut
  void _addDefaultQuotes() {
    _quotes = [
      Quote(text: "La vie est ce qui arrive quand on est occupé à faire d'autres projets.", author: "John Lennon"),
      Quote(text: "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il vient de vos propres actions.", author: "Dalaï Lama"),
      Quote(text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Peter Drucker"),
      Quote(text: "La seule façon de faire du bon travail est d'aimer ce que vous faites.", author: "Steve Jobs"),
      Quote(text: "Celui qui déplace une montagne commence par déplacer de petites pierres.", author: "Confucius"),
    ];
  }
  
  /// Sauvegarde les citations localement
  Future<void> _saveQuotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sauvegarder les citations générales
      final quotesJson = _quotes
          .map((quote) => jsonEncode(quote.toJson()))
          .toList();
      await prefs.setStringList(_quotesStorageKey, quotesJson);
      
      // Sauvegarder les citations favorites
      final favoritesJson = _favoriteQuotes
          .map((quote) => jsonEncode(quote.toJson()))
          .toList();
      await prefs.setStringList(_favoritesStorageKey, favoritesJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des citations: $e');
    }
  }
  
  /// Génère une nouvelle citation basée sur l'humeur
  Future<Quote?> generateQuoteForMood(MoodEntry? moodEntry) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Utiliser l'API Gemini pour générer une citation adaptée à l'humeur
      final moodScore = moodEntry?.moodScore;
      List<String>? themes;
      
      if (moodEntry?.note != null && moodEntry!.note!.isNotEmpty) {
        // Extraire des mots-clés de la note pour les utiliser comme thèmes
        final words = moodEntry.note!.split(' ')
            .where((word) => word.length > 4)
            .take(3)
            .toList();
        
        if (words.isNotEmpty) {
          themes = words;
        }
      }
      
      // Essayer de générer une citation avec l'API Gemini
      final quote = await _geminiService.generateInspirationalQuote(
        moodScore: moodScore,
        themes: themes,
      );
      
      if (quote != null) {
        final quoteWithTimestamp = Quote(
          text: quote.text,
          author: quote.author,
          timestamp: DateTime.now(),
          category: _getCategoryFromMood(moodScore),
        );
        
        _quotes.add(quoteWithTimestamp);
        _currentQuote = quoteWithTimestamp;
        await _saveQuotes();
        
        return quote;
      } else {
        // Si la génération échoue, utiliser une citation aléatoire existante
        return getRandomQuote();
      }
    } catch (e) {
      debugPrint('Erreur lors de la génération de citation: $e');
      return getRandomQuote();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Obtient une citation aléatoire des citations sauvegardées
  Quote? getRandomQuote() {
    if (_quotes.isEmpty) {
      _addDefaultQuotes();
    }
    
    if (_quotes.isNotEmpty) {
      _quotes.shuffle();
      _currentQuote = _quotes.first;
      notifyListeners();
      return _currentQuote;
    }
    
    return null;
  }
  
  /// Met à jour la citation quotidienne
  void _updateDailyQuote() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_quotes.isNotEmpty) {
      _currentQuote = _quotes[_random.nextInt(_quotes.length)];
      _lastQuoteDate = today;
      notifyListeners();
    }
  }
  
  /// Obtient une nouvelle citation aléatoire
  void refreshQuote() {
    if (_quotes.isEmpty) {
      _addDefaultQuotes();
    }
    
    if (_quotes.length > 1 && _currentQuote != null) {
      Quote newQuote;
      do {
        newQuote = _quotes[_random.nextInt(_quotes.length)];
      } while (_quotes.length > 1 && newQuote.text == _currentQuote?.text);
      
      _currentQuote = newQuote;
      notifyListeners();
    } else if (_quotes.isNotEmpty) {
      _currentQuote = _quotes.first;
      notifyListeners();
    }
  }
  
  /// Ajoute une citation aux favoris
  void addToFavorites(Quote quote) {
    if (!_favoriteQuotes.contains(quote)) {
      _favoriteQuotes.add(quote);
      _saveQuotes();
      notifyListeners();
    }
  }
  
  /// Retire une citation des favoris
  void removeFromFavorites(Quote quote) {
    _favoriteQuotes.removeWhere(
      (q) => q.text == quote.text && q.author == quote.author
    );
    _saveQuotes();
    notifyListeners();
  }
  
  /// Vérifie si une citation est dans les favoris
  bool isFavorite(Quote quote) {
    return _favoriteQuotes.any(
      (q) => q.text == quote.text && q.author == quote.author
    );
  }
  
  /// Détermine la catégorie de citation en fonction du score d'humeur
  String? _getCategoryFromMood(double? moodScore) {
    if (moodScore == null) return null;
    
    if (moodScore < 0.2) {
      return 'motivation';
    } else if (moodScore < 0.4) {
      return 'espoir';
    } else if (moodScore < 0.6) {
      return 'réflexion';
    } else if (moodScore < 0.8) {
      return 'inspiration';
    } else {
      return 'célébration';
    }
  }
} 