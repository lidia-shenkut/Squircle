import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AnalyticsScreen extends ConsumerWidget {
  final String groupId;
  const AnalyticsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Stats')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            emoji: '🔥',
            title: 'Most Active',
            value: 'Alex',
            subtitle: '142 messages this month',
            color: AppColors.streak,
          ),
          const SizedBox(height: 12),
          _StatCard(
            emoji: '📸',
            title: 'Top Memory Sender',
            value: 'Sam',
            subtitle: '23 photos shared',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _StatCard(
            emoji: '⚡',
            title: 'Longest Streak',
            value: 'Jordan',
            subtitle: '14-day streak',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _StatCard(
            emoji: '👻',
            title: 'Ghost Member',
            value: 'Riley',
            subtitle: 'No activity in 15 days',
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          _StatCard(
            emoji: '🖼️',
            title: 'Total Memories',
            value: '47',
            subtitle: 'Photos and videos shared',
            color: AppColors.xp,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                Text(value, style: AppTextStyles.titleLarge),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
