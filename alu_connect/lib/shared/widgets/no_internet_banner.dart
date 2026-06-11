import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final isOffline = results.isNotEmpty &&
            results.every((r) => r == ConnectivityResult.none);

        if (!isOffline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: ALUColors.redDim,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
