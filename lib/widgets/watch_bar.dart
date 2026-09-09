import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/content_provider.dart';

class WatchBar extends StatelessWidget {
  final ContentState state;
  const WatchBar({super.key, required this.state});

  String _formatHours(int minutes) {
    final hours = minutes / 60;
    return '${hours.toStringAsFixed(1)}h';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final pct = (state.progressFraction * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.missionProgress,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: state.progressFraction,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.hoursWatched(_formatHours(state.watchedMinutes)),
                  style: const TextStyle(fontSize: 12)),
              Text(t.hoursRemaining(_formatHours(state.remainingMinutes)),
                  style: const TextStyle(fontSize: 12)),
              Text(t.hoursTotal(_formatHours(state.totalMinutes)),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
