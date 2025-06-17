import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  static const String _storageKey = 'mood_entries';

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  MoodProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_storageKey);

      if (entriesJson != null) {
        _entries = entriesJson
            .map((json) => MoodEntry.fromJson(jsonDecode(json)))
            .toList();
        
        // Trier par date (plus récent en premier)
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des entrées: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = _entries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();
      
      await prefs.setStringList(_storageKey, entriesJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des entrées: $e');
    }
  }

  Future<void> addEntry(MoodEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    await _saveEntries();
  }

  Future<void> updateEntry(MoodEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
      await _saveEntries();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _saveEntries();
  }

  List<MoodEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.date.isAfter(start) && entry.date.isBefore(end);
    }).toList();
  }

  double getAverageMoodForDateRange(DateTime start, DateTime end) {
    final entriesInRange = getEntriesForDateRange(start, end);
    
    if (entriesInRange.isEmpty) return 0.5;
    
    final sum = entriesInRange.fold<double>(
      0, (sum, entry) => sum + entry.moodScore);
    
    return sum / entriesInRange.length;
  }
} 