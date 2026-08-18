import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../memory_wall/presentation/screens/memory_wall_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../games/presentation/screens/games_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../mood/presentation/screens/mood_screen.dart';

class GroupHomeScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupHomeScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends ConsumerState<GroupHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ChatScreen(groupId: widget.groupId),
      MemoryWallScreen(groupId: widget.groupId),
      EventsScreen(groupId: widget.groupId),
      GamesScreen(groupId: widget.groupId),
      MoodScreen(groupId: widget.groupId),
    ];
  }

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      selectedIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Chat',
    ),
    NavigationDestination(
      icon: Icon(Icons.photo_library_outlined),
      selectedIcon: Icon(Icons.photo_library_rounded),
      label: 'Memories',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event_rounded),
      label: 'Events',
    ),
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      selectedIcon: Icon(Icons.sports_esports_rounded),
      label: 'Games',
    ),
    NavigationDestination(
      icon: Icon(Icons.mood_outlined),
      selectedIcon: Icon(Icons.mood_rounded),
      label: 'Mood',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Squircle', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/groups/${widget.groupId}/analytics'),
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push('/groups/${widget.groupId}/invite'),
            tooltip: 'Invite friends',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
