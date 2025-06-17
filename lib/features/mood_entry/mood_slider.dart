import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MoodSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final bool showEmojis;
  
  const MoodSlider({
    super.key,
    this.initialValue = 0.5,
    required this.onChanged,
    this.showEmojis = true,
  });

  @override
  State<MoodSlider> createState() => _MoodSliderState();
}

class _MoodSliderState extends State<MoodSlider> with SingleTickerProviderStateMixin {
  late double _value;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Obtenir l'emoji correspondant à la valeur d'humeur
  String _getEmoji(double value) {
    if (value < 0.2) return '😢'; // Très triste
    if (value < 0.4) return '😔'; // Triste
    if (value < 0.6) return '😐'; // Neutre
    if (value < 0.8) return '🙂'; // Content
    return '😄'; // Très heureux
  }
  
  // Obtenir la couleur correspondant à la valeur d'humeur
  Color _getColor(double value) {
    final colors = AppTheme.moodColors;
    final index = (value * (colors.length - 1)).floor();
    final nextIndex = (index + 1).clamp(0, colors.length - 1);
    final t = (value * (colors.length - 1)) - index;
    
    return Color.lerp(colors[index], colors[nextIndex], t) ?? colors[index];
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          if (widget.showEmojis) ...[
            SizedBox(
              height: 60,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _getEmoji(_value),
                  key: ValueKey<String>(_getEmoji(_value)),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
          
          // Slider personnalisé
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getColor(_value),
              inactiveTrackColor: _getColor(_value).withOpacity(0.3),
              thumbColor: _getColor(_value),
              overlayColor: _getColor(_value).withOpacity(0.2),
              trackHeight: 8.0,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12.0,
                elevation: 4.0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 24.0,
              ),
            ),
            child: Slider(
              value: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                widget.onChanged(value);
              },
              min: 0.0,
              max: 1.0,
            ),
          ),
          
          // Étiquettes textuelles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Très mauvais',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.moodColors.first,
                  ),
                ),
                Text(
                  'Excellent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.moodColors.last,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 