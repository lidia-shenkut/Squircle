import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GamesScreen extends ConsumerWidget {
  final String groupId;
  const GamesScreen({super.key, required this.groupId});

  static const List<Map<String, dynamic>> _games = [
    {
      'title': 'Truth or Dare',
      'emoji': '🎭',
      'description': 'Reveal secrets or take on fun dares',
      'color': Color(0xFFFF6584),
    },
    {
      'title': 'Who Knows Best?',
      'emoji': '🧠',
      'description': 'How well do you know your friends?',
      'color': Color(0xFF6C63FF),
    },
    {
      'title': 'Trivia',
      'emoji': '❓',
      'description': 'Compete in a live trivia quiz',
      'color': Color(0xFF34C759),
    },
    {
      'title': 'Spin Wheel',
      'emoji': '🎡',
      'description': 'Spin and get a random challenge',
      'color': Color(0xFFFF9500),
    },
    {
      'title': 'Guess the Photo',
      'emoji': '🖼️',
      'description': 'Guess who posted this memory',
      'color': Color(0xFF5AC8FA),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Game Night 🎮', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text('Pick a game to play with the group',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final game = _games[i];
                  return _GameCard(
                    title: game['title'],
                    emoji: game['emoji'],
                    description: game['description'],
                    color: game['color'],
                    onTap: () {
                      // TODO: GameRepository.startGameSession
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(description,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline_rounded,
                color: color, size: 32),
          ],
        ),
      ),
    );
  }
}
