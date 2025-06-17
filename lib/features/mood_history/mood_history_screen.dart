import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/models/mood_entry.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/theme/app_theme.dart';
import '../shared/glass_container.dart';
import '../mood_entry/mood_entry_screen.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
            Tab(icon: Icon(Icons.show_chart), text: 'Graphique'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            _TimelineTab(),
            _ChartTab(),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final entries = moodProvider.entries;
    
    if (moodProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (entries.isEmpty) {
      return Center(
        child: GlassCard(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                'Aucune entrée d\'humeur',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodEntryScreen(),
                    ),
                  );
                },
                child: const Text('Ajouter une entrée'),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _MoodEntryCard(entry: entry);
      },
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  
  const _MoodEntryCard({required this.entry});

  Color _getMoodColor() {
    final colors = AppTheme.moodColors;
    final index = (entry.moodScore * (colors.length - 1)).floor();
    final nextIndex = (index + 1).clamp(0, colors.length - 1);
    final t = (entry.moodScore * (colors.length - 1)) - index;
    
    return Color.lerp(colors[index], colors[nextIndex], t) ?? colors[index];
  }
  
  String _getMoodEmoji() {
    if (entry.moodScore < 0.2) return '😢';
    if (entry.moodScore < 0.4) return '😔';
    if (entry.moodScore < 0.6) return '😐';
    if (entry.moodScore < 0.8) return '🙂';
    return '😄';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    final moodColor = _getMoodColor();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: GlassCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoodEntryScreen(editEntry: entry),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec emoji et date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Text(
                    _getMoodEmoji(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(entry.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      if (entry.tags.isNotEmpty)
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          children: entry.tags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Note
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                entry.note!,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Image
            if (entry.imagePath != null) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius / 2),
                child: Image.file(
                  File(entry.imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.2),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartTab extends StatefulWidget {
  const _ChartTab();

  @override
  State<_ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<_ChartTab> {
  // Période sélectionnée pour le graphique
  String _selectedPeriod = '7j';
  
  // Périodes disponibles
  final List<String> _periods = ['7j', '30j', '90j', 'Tout'];
  
  // Obtenir la date de début en fonction de la période sélectionnée
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '7j':
        return now.subtract(const Duration(days: 7));
      case '30j':
        return now.subtract(const Duration(days: 30));
      case '90j':
        return now.subtract(const Duration(days: 90));
      case 'Tout':
      default:
        return DateTime(2000); // Date très ancienne pour tout inclure
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final startDate = _getStartDate();
    final now = DateTime.now();
    
    // Filtrer les entrées pour la période sélectionnée
    final entries = moodProvider.entries
        .where((entry) => entry.date.isAfter(startDate) && entry.date.isBefore(now))
        .toList();
    
    if (moodProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (entries.isEmpty) {
      return Center(
        child: GlassCard(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.show_chart,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                'Aucune donnée pour cette période',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          // Sélecteur de période
          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _periods.map((period) {
                final isSelected = period == _selectedPeriod;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Graphique
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: _buildChart(entries),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Statistiques
          GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Moyenne',
                  _calculateAverage(entries),
                  Icons.equalizer,
                ),
                _buildStatItem(
                  context,
                  'Maximum',
                  _calculateMax(entries),
                  Icons.arrow_upward,
                ),
                _buildStatItem(
                  context,
                  'Minimum',
                  _calculateMin(entries),
                  Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart(List<MoodEntry> entries) {
    // Trier les entrées par date
    entries.sort((a, b) => a.date.compareTo(b.date));
    
    // Créer les points pour le graphique
    final spots = entries.map((entry) {
      // Convertir la date en valeur x (nombre de jours depuis l'époque)
      final x = entry.date.millisecondsSinceEpoch.toDouble();
      // L'humeur est déjà entre 0 et 1
      final y = entry.moodScore;
      return FlSpot(x, y);
    }).toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = '😢';
                    break;
                  case 1:
                    text = '😄';
                    break;
                  default:
                    return const SizedBox.shrink();
                }
                return Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getDateInterval(entries),
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: entries.first.date.millisecondsSinceEpoch.toDouble(),
        maxX: entries.last.date.millisecondsSinceEpoch.toDouble(),
        minY: 0,
        maxY: 1,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.cardColor.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${DateFormat('dd/MM/yyyy').format(date)}\n',
                  const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${(spot.y * 100).toInt()}%',
                      style: TextStyle(
                        color: _getMoodColor(spot.y),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: const LinearGradient(
              colors: AppTheme.moodColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: _getMoodColor(spot.y),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: AppTheme.moodColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Obtenir l'intervalle approprié pour les dates en fonction du nombre d'entrées
  double _getDateInterval(List<MoodEntry> entries) {
    if (entries.isEmpty || entries.length == 1) return 1;
    
    final firstDate = entries.first.date;
    final lastDate = entries.last.date;
    final daysDifference = lastDate.difference(firstDate).inDays;
    
    // Calculer un intervalle qui donnera environ 5-7 labels
    final millisecondsPerDay = const Duration(days: 1).inMilliseconds;
    
    if (daysDifference <= 7) {
      // Pour une semaine ou moins, montrer chaque jour
      return millisecondsPerDay.toDouble();
    } else if (daysDifference <= 30) {
      // Pour un mois, montrer tous les 3-4 jours
      return (millisecondsPerDay * 4).toDouble();
    } else if (daysDifference <= 90) {
      // Pour trois mois, montrer toutes les semaines
      return (millisecondsPerDay * 7).toDouble();
    } else {
      // Pour plus longtemps, montrer tous les mois
      return (millisecondsPerDay * 30).toDouble();
    }
  }
  
  // Calculer la moyenne des humeurs
  String _calculateAverage(List<MoodEntry> entries) {
    if (entries.isEmpty) return '0%';
    
    final sum = entries.fold<double>(0, (sum, entry) => sum + entry.moodScore);
    final average = sum / entries.length;
    
    return '${(average * 100).toInt()}%';
  }
  
  // Trouver l'humeur maximale
  String _calculateMax(List<MoodEntry> entries) {
    if (entries.isEmpty) return '0%';
    
    final max = entries.map((e) => e.moodScore).reduce((a, b) => a > b ? a : b);
    
    return '${(max * 100).toInt()}%';
  }
  
  // Trouver l'humeur minimale
  String _calculateMin(List<MoodEntry> entries) {
    if (entries.isEmpty) return '0%';
    
    final min = entries.map((e) => e.moodScore).reduce((a, b) => a < b ? a : b);
    
    return '${(min * 100).toInt()}%';
  }
  
  // Obtenir la couleur correspondant à une valeur d'humeur
  Color _getMoodColor(double value) {
    final colors = AppTheme.moodColors;
    final index = (value * (colors.length - 1)).floor();
    final nextIndex = (index + 1).clamp(0, colors.length - 1);
    final t = (value * (colors.length - 1)) - index;
    
    return Color.lerp(colors[index], colors[nextIndex], t) ?? colors[index];
  }
  
  // Construire un élément de statistique
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
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