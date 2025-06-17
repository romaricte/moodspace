# MoodSpace - Journal de bien-être et d'humeur

MoodSpace est une application Flutter élégante et moderne qui vous permet de suivre votre humeur et votre bien-être au quotidien. Avec une interface utilisateur soignée utilisant des effets glassmorphism, l'application offre une expérience visuelle agréable et apaisante.

## Fonctionnalités

- **Écran d'accueil** avec effet glassmorphism, affichant :
  - Une citation inspirante (différente chaque jour)
  - Un bouton pour noter son humeur

- **Saisie d'humeur** intuitive avec :
  - Un slider visuel avec emojis pour noter son humeur
  - Un champ de texte pour ajouter des notes personnelles
  - La possibilité d'ajouter une image (photo ou depuis la galerie)
  - Des tags pour catégoriser les entrées

- **Historique des humeurs** via :
  - Une timeline verticale affichant toutes les entrées
  - Un graphique interactif montrant l'évolution de l'humeur
  - Des statistiques sur votre bien-être (moyenne, minimum, maximum)

- **Citations générées par IA** :
  - Citations inspirantes générées par l'API Gemini de Google
  - Citations adaptées à votre humeur actuelle
  - Possibilité de sauvegarder vos citations préférées

## Design moderne

L'application utilise plusieurs techniques de design modernes :

- **Glassmorphism** : effet de verre dépoli sur les cartes et boutons
- **Dégradés subtils** : pour les arrière-plans et les éléments d'interface
- **Animations fluides** : pour une expérience utilisateur agréable
- **Mode sombre** : interface optimisée pour le confort visuel

## Structure du projet

Le projet est organisé selon une architecture propre et modulaire :

```
lib/
  ├── core/
  │   ├── models/         # Modèles de données
  │   ├── providers/      # Gestion d'état avec Provider
  │   ├── services/       # Services (API Gemini, etc.)
  │   ├── theme/          # Thème de l'application
  │   ├── widgets/        # Widgets réutilisables
  │   └── utils/          # Utilitaires
  │
  ├── features/
  │   ├── home/           # Écran d'accueil
  │   ├── mood_entry/     # Saisie d'humeur
  │   ├── mood_history/   # Historique des humeurs
  │   ├── quotes/         # Gestion des citations
  │   └── shared/         # Widgets partagés
  │
  └── main.dart           # Point d'entrée de l'application
```

## Packages utilisés

- **provider** : Gestion d'état
- **fl_chart** : Visualisation des données d'humeur
- **glassmorphism** : Effets de verre dépoli
- **image_picker** : Sélection d'images
- **shared_preferences** : Stockage local des entrées
- **intl** : Formatage des dates
- **google_fonts** : Typographie soignée
- **flutter_svg** : Support pour les icônes vectorielles
- **google_generative_ai** : Intégration de l'API Gemini
- **flutter_dotenv** : Gestion des variables d'environnement

## Installation

1. Assurez-vous d'avoir Flutter installé (version 3.8.0 ou supérieure)
2. Clonez ce dépôt
3. Exécutez `flutter pub get` pour installer les dépendances
4. Configurez l'API Gemini (voir ci-dessous)
5. Lancez l'application avec `flutter run`

## Configuration de l'API Gemini

Pour utiliser la génération de citations par IA, vous devez configurer l'API Gemini :

1. Créez un compte sur [Google AI Studio](https://ai.google.dev/)
2. Obtenez une clé API pour Gemini
3. Créez un fichier `.env` à la racine du projet avec le contenu suivant :
   ```
   GEMINI_API_KEY=VOTRE_CLÉ_API_ICI
   ```
4. Redémarrez l'application

> **Note** : Si vous ne configurez pas l'API Gemini, l'application utilisera des citations prédéfinies.

## Personnalisation

Vous pouvez facilement personnaliser l'application :

- Modifiez les couleurs dans `lib/core/theme/app_theme.dart`
- Ajoutez vos propres citations dans `assets/quotes/quotes.json`
- Personnalisez les tags disponibles dans `lib/features/mood_entry/mood_entry_screen.dart`
- Ajustez les paramètres de génération de l'API Gemini dans `lib/core/services/gemini_service.dart`

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.
