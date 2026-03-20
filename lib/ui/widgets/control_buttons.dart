import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback? onSkipPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSkipNext;
  final bool isPlaying;

  const ControlButtons({
    super.key,
    this.onSkipPrevious,
    this.onPlayPause,
    this.onSkipNext,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip Previous Button
            _ControlButton(
              icon: Icons.skip_previous,
              onPressed: onSkipPrevious ?? () {},
              iconSize: 28,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            // Play/Pause Button (Highlighted)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[400],
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onPlayPause ?? () {},
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 32,
                splashRadius: 28,
                constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
              ),
            ),
            const SizedBox(width: 16),
            // Skip Next Button
            _ControlButton(
              icon: Icons.skip_next,
              onPressed: onSkipNext ?? () {},
              iconSize: 28,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.iconSize = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: iconSize, color: color ?? Colors.grey[600]),
        ),
      ),
    );
  }
}
