import 'package:flutter/material.dart';
import '../../../../core/widgets/neumorphic_card.dart';

class MotivationalQuoteCard extends StatelessWidget {
  final Map<String, String> quote;

  const MotivationalQuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
        width: double.infinity,
        child: NeumorphicCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                quote['quote']!,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '— ${quote['author']}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ));
  }
}
