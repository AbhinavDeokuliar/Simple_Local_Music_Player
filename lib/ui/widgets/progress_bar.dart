import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final Duration currentDuration;
  final Duration totalDuration;
  final ValueChanged<double>? onChanged;

  const ProgressBar({
    super.key,
    required this.currentDuration,
    required this.totalDuration,
    this.onChanged,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        .replaceFirst(RegExp(r'^0:'), '');
  }

  @override
  Widget build(BuildContext context) {
    double sliderValue = totalDuration.inSeconds > 0
        ? currentDuration.inSeconds / totalDuration.inSeconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Progress Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0,
                elevation: 4.0,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: sliderValue,
              onChanged: (value) {
                if (onChanged != null) {
                  onChanged!(value * totalDuration.inSeconds);
                }
              },
              activeColor: Colors.blue[400],
              inactiveColor: Colors.grey[300],
            ),
          ),
          // Time Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentDuration),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDuration(totalDuration),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
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
