import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quote.dart';

class GeminiService {
  // Récupérer la clé API depuis le fichier .env
  static String? get _apiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      debugPrint('Erreur lors de l\'accès à la clé API: $e');
      return null;
    }
  }
  
  GenerativeModel? _model;
  
  GeminiService() {
    _initModel();
  }
  
  void _initModel() {
    final apiKey = _apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 200,
        ),
      );
    }
  }
  
  /// Génère une citation inspirante en fonction de l'humeur
  Future<Quote?> generateInspirationalQuote({
    double? moodScore,
    List<String>? themes,
  }) async {
    try {
      if (_model == null) {
        debugPrint('⚠️ Clé API Gemini non configurée ou modèle non initialisé');
        return _getFallbackQuote(moodScore);
      }
      
      final prompt = _buildPrompt(moodScore, themes);
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final responseText = response.text;
      
      if (responseText == null) {
        debugPrint('Réponse vide de l\'API Gemini');
        return _getFallbackQuote(moodScore);
      }
      
      return _parseQuote(responseText);
    } catch (e) {
      debugPrint('Erreur lors de la génération de citation: $e');
      return _getFallbackQuote(moodScore);
    }
  }
  
  String _buildPrompt(double? moodScore, List<String>? themes) {
    String moodDescription = '';
    if (moodScore != null) {
      if (moodScore < 0.2) {
        moodDescription = 'triste ou déprimé';
      } else if (moodScore < 0.4) {
        moodDescription = 'un peu mélancolique';
      } else if (moodScore < 0.6) {
        moodDescription = 'neutre';
      } else if (moodScore < 0.8) {
        moodDescription = 'positif';
      } else {
        moodDescription = 'très heureux et enthousiaste';
      }
    }
    
    String themesDescription = '';
    if (themes != null && themes.isNotEmpty) {
      themesDescription = 'sur les thèmes: ${themes.join(", ")}';
    }
    
    return '''
    Génère une citation inspirante courte (maximum 200 caractères) en français ${moodDescription.isNotEmpty ? 'pour quelqu\'un qui se sent $moodDescription' : ''} ${themesDescription.isNotEmpty ? themesDescription : ''}.
    
    La citation doit être profonde, mémorable et positive. Elle doit être attribuée à un auteur, philosophe, ou personnage historique connu.
    
    Réponds uniquement avec la citation au format suivant:
    "Citation" - Auteur
    ''';
  }
  
  Quote _parseQuote(String responseText) {
    // Nettoyer la réponse
    final cleanText = responseText.trim();
    
    // Chercher le format "Citation" - Auteur
    final quoteRegex = RegExp(r'"([^"]+)"\s*-\s*(.+)');
    final match = quoteRegex.firstMatch(cleanText);
    
    if (match != null && match.groupCount >= 2) {
      final text = match.group(1)!.trim();
      final author = match.group(2)!.trim();
      return Quote(text: text, author: author);
    }
    
    // Si le format n'est pas exactement comme attendu, essayer de séparer par "-"
    final parts = cleanText.split('-');
    if (parts.length >= 2) {
      final text = parts[0].trim().replaceAll('"', '');
      final author = parts[1].trim();
      return Quote(text: text, author: author);
    }
    
    // Si tout échoue, renvoyer une citation générique
    return Quote(
      text: cleanText.replaceAll('"', ''),
      author: 'Inconnu',
    );
  }
  
  /// Retourne une citation de secours si l'API n'est pas disponible
  Quote _getFallbackQuote(double? moodScore) {
    final quotes = [
      Quote(text: "La vie est ce qui arrive quand on est occupé à faire d'autres projets.", author: "John Lennon"),
      Quote(text: "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il vient de vos propres actions.", author: "Dalaï Lama"),
      Quote(text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Peter Drucker"),
      Quote(text: "La seule façon de faire du bon travail est d'aimer ce que vous faites.", author: "Steve Jobs"),
      Quote(text: "Celui qui déplace une montagne commence par déplacer de petites pierres.", author: "Confucius"),
    ];
    
    if (moodScore != null) {
      // Sélectionner une citation en fonction de l'humeur
      if (moodScore < 0.3) {
        return Quote(
          text: "La plus grande gloire n'est pas de ne jamais tomber, mais de se relever à chaque chute.",
          author: "Confucius",
        );
      } else if (moodScore < 0.6) {
        return Quote(
          text: "Le succès n'est pas final, l'échec n'est pas fatal : c'est le courage de continuer qui compte.",
          author: "Winston Churchill",
        );
      } else {
        return Quote(
          text: "Le bonheur est la seule chose qui se multiplie quand on le partage.",
          author: "Albert Schweitzer",
        );
      }
    }
    
    // Retourner une citation aléatoire
    quotes.shuffle();
    return quotes.first;
  }
} 