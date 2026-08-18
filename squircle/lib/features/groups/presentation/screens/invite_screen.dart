import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class InviteScreen extends ConsumerWidget {
  final String groupId;
  const InviteScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load real invite code from GroupRepository
    const inviteCode = 'SQR123';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Invite Friends')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Share the code', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text('Your friends enter this code to join',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Code card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(inviteCode,
                      style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary, letterSpacing: 6)),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(
                          const ClipboardData(text: inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invite code copied!')),
                      );
                    },
                    tooltip: 'Copy code',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                // TODO: share_plus share link
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share Invite Link'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: regenerate invite code
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Regenerate Code'),
            ),
          ],
        ),
      ),
    );
  }
}
