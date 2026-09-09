import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/content_provider.dart';

class EpisodeList extends ConsumerWidget {
  final int contentId;
  final List<Map<String, dynamic>> episodes;
  final Set<int> watchedEpisodeNumbers;

  const EpisodeList({
    super.key,
    required this.contentId,
    required this.episodes,
    required this.watchedEpisodeNumbers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: episodes.map((ep) {
        final episodeNumber = ep['episode_number'] as int;
        final watched = watchedEpisodeNumbers.contains(episodeNumber);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$episodeNumber.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${ep['name'] ?? ''} · ${ep['runtime_minutes']} min',
                  style: TextStyle(
                    fontSize: 13,
                    decoration: watched ? TextDecoration.lineThrough : null,
                    color: watched
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: Checkbox(
                  value: watched,
                  onChanged: (value) {
                    ref.read(contentProvider.notifier).toggleEpisodeWatched(
                          contentId,
                          episodeNumber,
                          value ?? false,
                        );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
