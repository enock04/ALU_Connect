import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/message_model.dart';

class CommunityCard extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;
  final VoidCallback onJoinLeave;
  final bool joining;

  const CommunityCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onJoinLeave,
    this.joining = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ALUColors.border),
        ),
        child: Row(
          children: [
            // avatar / icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ALUColors.navyDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ALUColors.border),
              ),
              child: Center(
                child: Text(
                  room.name.isNotEmpty ? room.name[0].toUpperCase() : '#',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: ALUColors.navyLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: ALUColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0)
                        _UnreadBadge(count: room.unreadCount),
                    ],
                  ),
                  if (room.description != null && room.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      room.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ALUColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 12, color: ALUColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${room.memberCount} member${room.memberCount == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 11, color: ALUColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // join / leave button
            GestureDetector(
              onTap: joining ? null : onJoinLeave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: room.isJoined
                      ? ALUColors.surface
                      : ALUColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: room.isJoined ? ALUColors.border : ALUColors.red,
                  ),
                ),
                child: joining
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: ALUColors.red,
                        ),
                      )
                    : Text(
                        room.isJoined ? 'Joined' : 'Join',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: room.isJoined ? ALUColors.textMuted : ALUColors.red,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ALUColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// used in the team-chat section of CommunitiesScreen
class TeamChatCard extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const TeamChatCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ALUColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ALUColors.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ALUColors.goldDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 20, color: ALUColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: ALUColors.gold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (room.lastMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      room.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: ALUColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (room.unreadCount > 0)
              _UnreadBadge(count: room.unreadCount),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: ALUColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
