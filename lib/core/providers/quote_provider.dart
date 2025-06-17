import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteProvider extends ChangeNotifier {
  List<Quote> _quotes = [];
  Quote? _dailyQuote;
  bool _isLoading = false;
  final Random _random = Random();
  DateTime? _lastQuoteDate;

  Quote? get dailyQuote => _dailyQuote;
  bool get isLoading => _isLoading;

  QuoteProvider() {
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chargement des citations depuis un fichier JSON
      final String data = await rootBundle.loadString('assets/quotes/quotes.json');
      final List<dynamic> jsonList = json.decode(data);
      
      _quotes = jsonList.map((json) => Quote.fromJson(json)).toList();
      _updateDailyQuote();
    } catch (e) {
      debugPrint('Erreur lors du chargement des citations: $e');
      // En cas d'erreur, utiliser quelques citations par défaut
      _quotes = [
        Quote(text: "La vie est ce qui arrive quand on est occupé à faire d'autres projets.", author: "John Lennon"),
        Quote(text: "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il vient de vos propres actions.", author: "Dalai Lama"),
        Quote(text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Peter Drucker"),
      ];
      _updateDailyQuote();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateDailyQuote() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Vérifier si nous avons déjà une citation pour aujourd'hui
    if (_lastQuoteDate != null && 
        _lastQuoteDate!.year == today.year && 
        _lastQuoteDate!.month == today.month && 
        _lastQuoteDate!.day == today.day) {
      return; // Déjà une citation pour aujourd'hui
    }
    
    if (_quotes.isNotEmpty) {
      _dailyQuote = _quotes[_random.nextInt(_quotes.length)];
      _lastQuoteDate = today;
      notifyListeners();
    }
  }

  // Forcer une nouvelle citation aléatoire
  void getNewRandomQuote() {
    if (_quotes.isNotEmpty) {
      Quote newQuote;
      do {
        newQuote = _quotes[_random.nextInt(_quotes.length)];
      } while (_quotes.length > 1 && newQuote.text == _dailyQuote?.text);
      
      _dailyQuote = newQuote;
      notifyListeners();
    }
  }
} 