import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Squircles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profileEdit),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _buildEmptyState(context),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () => context.push(AppRoutes.joinGroup),
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Join'),
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => context.push(AppRoutes.createGroup),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_outlined,
                  size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 28),
            Text('No Squircles yet',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Create a private group or join your friends with an invite code',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.createGroup),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create a Squircle'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.joinGroup),
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Join with invite code'),
            ),
          ],
        ),
      ),
    );
  }
}
