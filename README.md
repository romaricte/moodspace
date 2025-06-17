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
  │   ├── theme/          # Thème de l'application
  │   └── utils/          # Utilitaires
  │
  ├── features/
  │   ├── home/           # Écran d'accueil
  │   ├── mood_entry/     # Saisie d'humeur
  │   ├── mood_history/   # Historique des humeurs
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

## Installation

1. Assurez-vous d'avoir Flutter installé (version 3.8.0 ou supérieure)
2. Clonez ce dépôt
3. Exécutez `flutter pub get` pour installer les dépendances
4. Lancez l'application avec `flutter run`

## Personnalisation

Vous pouvez facilement personnaliser l'application :

- Modifiez les couleurs dans `lib/core/theme/app_theme.dart`
- Ajoutez vos propres citations dans `assets/quotes/quotes.json`
- Personnalisez les tags disponibles dans `lib/features/mood_entry/mood_entry_screen.dart`

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.
