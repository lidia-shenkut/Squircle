import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MoodScreen extends ConsumerStatefulWidget {
  final String groupId;
  const MoodScreen({super.key, required this.groupId});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  String? _selectedMood;
  bool _submitted = false;

  static const _moods = [
    {'label': 'Happy', 'emoji': '😊', 'color': AppColors.moodHappy},
    {'label': 'Sad', 'emoji': '😢', 'color': AppColors.moodSad},
    {'label': 'Excited', 'emoji': '🤩', 'color': AppColors.moodExcited},
    {'label': 'Tired', 'emoji': '😴', 'color': AppColors.moodTired},
    {'label': 'Anxious', 'emoji': '😰', 'color': AppColors.moodAnxious},
    {'label': 'Grateful', 'emoji': '🙏', 'color': AppColors.moodGrateful},
  ];

  void _submitMood() {
    if (_selectedMood == null) return;
    // TODO: MoodRepository.submitMoodCheckIn
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('How are you feeling?', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text('Share your mood with the group',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            if (!_submitted) ...[
              // Mood grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: _moods.map((mood) {
                  final selected = _selectedMood == mood['label'];
                  final color = mood['color'] as Color;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMood = mood['label'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? color : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood['emoji'] as String,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 6),
                          Text(mood['label'] as String,
                              style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _selectedMood != null ? _submitMood : null,
                child: const Text('Share Mood'),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text('Mood shared!',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Your friends can see how you\'re feeling',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
