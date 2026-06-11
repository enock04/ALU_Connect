import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showSenderName;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 12,
        right: isMe ? 12 : 64,
        top: showSenderName ? 10 : 3,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // sender name (only shown when sender changes)
          if (showSenderName && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: ALUColors.navyLight,
                ),
              ),
            ),
          // bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: isMe ? ALUColors.red.withValues(alpha: 0.9) : ALUColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe ? null : Border.all(color: ALUColors.border),
            ),
            child: Text(
              message.body,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isMe ? Colors.white : ALUColors.textPrimary,
              ),
            ),
          ),
          // timestamp
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(
                _formatTime(message.sentAt),
                style: const TextStyle(fontSize: 10, color: ALUColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('d MMM, HH:mm').format(dt);
  }
}

// day separator line shown between messages on different days
class DaySeparator extends StatelessWidget {
  final DateTime date;
  const DaySeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;

    String label;
    if (diff == 0) {
      label = 'Today';
    } else if (diff == 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: ALUColors.border, thickness: 0.7)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: ALUColors.textMuted),
            ),
          ),
          const Expanded(child: Divider(color: ALUColors.border, thickness: 0.7)),
        ],
      ),
    );
  }
}
