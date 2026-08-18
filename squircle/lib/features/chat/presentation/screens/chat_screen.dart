import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  const ChatScreen({super.key, required this.groupId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Dummy messages for UI preview
  final List<Map<String, dynamic>> _dummyMessages = [
    {
      'sender': 'Alex',
      'content': 'Hey everyone! 👋',
      'time': '10:00 AM',
      'isMe': false,
      'avatar': '😎',
    },
    {
      'sender': 'You',
      'content': 'What\'s up! Ready for tonight?',
      'time': '10:02 AM',
      'isMe': true,
      'avatar': '🦊',
    },
    {
      'sender': 'Sam',
      'content': 'Yesss let\'s gooo 🔥🔥',
      'time': '10:03 AM',
      'isMe': false,
      'avatar': '🥳',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _dummyMessages.length,
            itemBuilder: (context, i) {
              final msg = _dummyMessages[i];
              return _MessageBubble(
                sender: msg['sender'],
                content: msg['content'],
                time: msg['time'],
                isMe: msg['isMe'],
                avatar: msg['avatar'],
              );
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: AppColors.textSecondary),
                onPressed: () {},
                tooltip: 'Attach',
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: send message via ChatRepository
                  if (_messageController.text.trim().isNotEmpty) {
                    setState(() {
                      _dummyMessages.add({
                        'sender': 'You',
                        'content': _messageController.text.trim(),
                        'time': 'Now',
                        'isMe': true,
                        'avatar': '🦊',
                      });
                      _messageController.clear();
                    });
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String sender;
  final String content;
  final String time;
  final bool isMe;
  final String avatar;

  const _MessageBubble({
    required this.sender,
    required this.content,
    required this.time,
    required this.isMe,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceVariant,
              child: Text(avatar, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(sender,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(time,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontSize: 10)),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
