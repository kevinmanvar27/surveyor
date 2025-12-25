import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';

/// Simple theme toggle button for the app bar
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final autoSunset = ref.watch(autoSunsetModeProvider);
    
    return IconButton(
      onPressed: () {
        // Disable auto-sunset when user manually toggles
        if (autoSunset) {
          ref.read(autoSunsetModeProvider.notifier).setAutoSunset(false);
        }
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.amber : Colors.orange,
          ),
          // Auto-sunset indicator
          if (autoSunset)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: autoSunset ? 'Auto theme (tap to disable)' : 'Toggle theme',
    );
  }
}
