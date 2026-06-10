import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/communities_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

// Reusable chat screen — used by both Communities and Launchpad team chats.
// Just pass in the roomId; the provider handles everything else.
class ChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const ChatRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // mark room as read when entering
    Future.microtask(() {
      ref.read(communitiesProvider.notifier).markRead(widget.roomId);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    if (!_scrollCtrl.hasClients) return;
    if (animate) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  String _roomName() {
    final comState = ref.read(communitiesProvider);
    final match = [
      ...comState.communities,
      ...comState.myTeamChats,
    ].where((r) => r.id == widget.roomId).toList();
    return match.isNotEmpty ? match.first.name : 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.roomId));

    // scroll to bottom when new messages arrive
    ref.listen<ChatState>(chatProvider(widget.roomId), (prev, next) {
      if (prev != null && next.messages.length > prev.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animate: true);
        });
      }
    });

    return Scaffold(
      backgroundColor: ALUColors.background,
      appBar: AppBar(
        backgroundColor: ALUColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ALUColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _roomName(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ALUColors.textPrimary,
              ),
            ),
            if (chatState.loading)
              const Text(
                'Loading…',
                style: TextStyle(fontSize: 11, color: ALUColors.textMuted),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: ALUColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.loading
                ? const Center(child: CircularProgressIndicator(color: ALUColors.navyLight))
                : chatState.messages.isEmpty
                    ? _EmptyChat(roomName: _roomName())
                    : _MessageList(
                        messages: chatState.messages,
                        scrollCtrl: _scrollCtrl,
                      ),
          ),
          ChatInputBar(
            sending: chatState.sending,
            onSend: (text) {
              ref.read(chatProvider(widget.roomId).notifier).sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  final List<MessageModel> messages;
  final ScrollController scrollCtrl;

  const _MessageList({required this.messages, required this.scrollCtrl});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollCtrl.hasClients) {
        widget.scrollCtrl.jumpTo(widget.scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameSender(int index) {
    if (index == 0) return false;
    final prev = widget.messages[index - 1];
    final curr = widget.messages[index];
    return prev.senderId == curr.senderId &&
        curr.sentAt.difference(prev.sentAt).inMinutes < 5;
  }

  @override
  Widget build(BuildContext context) {
    final msgs = widget.messages;

    return ListView.builder(
      controller: widget.scrollCtrl,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final msg = msgs[i];
        final showDay = i == 0 || !_isSameDay(msgs[i - 1].sentAt, msg.sentAt);
        final sameSender = _isSameSender(i);
        final isLast = i == msgs.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDay) DaySeparator(date: msg.sentAt),
            MessageBubble(
              message: msg,
              showSenderName: !sameSender,
              showTimestamp: isLast || !_isSameSender(i + 1 < msgs.length ? i + 1 : i),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String roomName;
  const _EmptyChat({required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ALUColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: ALUColors.border),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: ALUColors.textMuted),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to $roomName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ALUColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to say something.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ALUColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
