// lib/features/feed/screens/feed_screen.dart
// Home feed — scrollable list of upcoming events with category filter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/event_model.dart';
import '../providers/feed_provider.dart';
import '../widgets/event_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: ALUColors.background,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'ALU ',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Connect',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ALUColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: ALUColors.red,
        backgroundColor: ALUColors.card,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _CategoryFilter()),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: ALUColors.red),
                ),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: ALUColors.textMuted),
                  ),
                ),
              )
            else if (state.filtered.isEmpty)
              const SliverFillRemaining(child: _EmptyFeed())
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => EventCard(event: state.filtered[i]),
                    childCount: state.filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(feedProvider).selectedCategory;
    final categories = [null, ...EventCategory.values];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat;
          final label = cat == null
              ? 'All'
              : cat.name[0].toUpperCase() + cat.name.substring(1);
          final color =
              cat == null ? ALUColors.red : categoryColor(cat);

          return GestureDetector(
            onTap: () =>
                ref.read(feedProvider.notifier).selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? color : ALUColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : ALUColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: ALUColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'No events yet',
            style:
                TextStyle(color: ALUColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back soon',
            style: TextStyle(color: ALUColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
