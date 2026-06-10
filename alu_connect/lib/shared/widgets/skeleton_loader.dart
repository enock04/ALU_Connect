import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_theme.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ALUColors.card,
      highlightColor: ALUColors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// skeleton card for the feed while posts are loading
class FeedCardSkeleton extends StatelessWidget {
  const FeedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SkeletonBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SkeletonBox(width: 140, height: 12),
              SizedBox(height: 6),
              SkeletonBox(width: 80, height: 10),
            ]),
          ]),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 14),
          SizedBox(height: 6),
          SkeletonBox(width: 200, height: 12),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 130, radius: 12),
        ],
      ),
    );
  }
}

class FeedSkeletonList extends StatelessWidget {
  final int count;
  const FeedSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (_, _) => const FeedCardSkeleton(),
      );
}
