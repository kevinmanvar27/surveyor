import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/simple_button.dart';
import 'core/widgets/simple_card.dart';
import 'core/theme/widgets/apple_theme_toggle.dart';

class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Design Demo'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Toggle
            const AppleThemeToggle(),
            const SizedBox(height: 24),
            
            // Typography Demo
            Text(
              'Typography Demo',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            
            Text(
              'This is a headline',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            
            Text(
              'This is body text that demonstrates the Apple-style typography system with proper letter spacing and font weights.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            
            Text(
              'This is secondary text',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            
            // Buttons Demo
            Text(
              'Buttons Demo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            SimpleButton(
              text: 'Primary Button',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            
            SimpleButton(
              text: 'Outlined Button',
              isOutlined: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            
            SimpleButton(
              text: 'Destructive Button',
              isDestructive: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            
            SimpleButton(
              text: 'Large Button',
              isLarge: true,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            
            // Cards Demo
            Text(
              'Cards Demo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            SimpleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a card with Apple-style design including proper shadows, rounded corners, and spacing.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            SimpleCard(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card tapped!')),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.touch_app),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tappable Card',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Tap me to see the interaction',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Input Demo
            Text(
              'Input Demo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 32),
            
            // Status Colors Demo
            Text(
              'Status Colors Demo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Primary',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSuccess,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Success',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardError,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}