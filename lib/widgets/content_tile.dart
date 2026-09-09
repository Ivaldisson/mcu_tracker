import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/content_item.dart';
import '../services/content_provider.dart';
import '../services/tmdb_service.dart';
import 'episode_list.dart';

class ContentTile extends ConsumerStatefulWidget {
  final ContentItem item;
  final bool watched;
  final bool showReleaseDate;

  const ContentTile({
    super.key,
    required this.item,
    required this.watched,
    this.showReleaseDate = false,
  });

  @override
  ConsumerState<ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends ConsumerState<ContentTile> {
  final TmdbService _tmdb = TmdbService();
  bool _expanded = false;
  bool _loading = false;
  TmdbResult? _result;

  Color _importanceColor(String importance) {
    switch (importance) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'medium':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  String _importanceCode(String importance) {
    switch (importance) {
      case 'critical':
        return 'CRIT';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MED';
      default:
        return 'LOW';
    }
  }

  Future<void> _handleTap() async {
    setState(() => _expanded = !_expanded);

    if (_expanded && _result == null) {
      setState(() => _loading = true);
      final result = await _tmdb.getSynopsis(
        contentId: widget.item.id,
        title: widget.item.title,
        mediaType: widget.item.mediaType,
        itemRuntimeMinutes: widget.item.runtimeMinutes,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
      if (result.episodes.isNotEmpty) {
        // Ververst de globale state (watchbar etc.) nu de episode-cache
        // gevuld is; heeft geen effect op wat dit widget zelf al toont.
        ref.read(contentProvider.notifier).refreshAfterTmdbCache();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final item = widget.item;
    final state = ref.watch(contentProvider);
    final fullyWatched = state.isFullyWatched(item);

    return Column(
      children: [
        InkWell(
          onTap: _handleTap,
          child: ListTile(
            leading: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _importanceColor(item.importance),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  _importanceCode(item.importance),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: _importanceColor(item.importance),
                  ),
                ),
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration: fullyWatched ? TextDecoration.lineThrough : null,
                color: fullyWatched ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              [
                if (state.episodeAggregates.containsKey(item.id))
                  '${(state.episodeAggregates[item.id]!.watchedMinutes / 60).toStringAsFixed(1)}h/'
                      '${(state.episodeAggregates[item.id]!.totalMinutes / 60).toStringAsFixed(1)}h'
                else
                  '${item.runtimeMinutes} min',
                if (widget.showReleaseDate && item.releaseDate != null)
                  MaterialLocalizations.of(context)
                      .formatMediumDate(item.releaseDate!),
                if (item.timeyWimey) t.estimatedPlacement,
              ].join(' · '),
            ),
            trailing: Checkbox(
              value: fullyWatched,
              onChanged: (value) {
                ref
                    .read(contentProvider.notifier)
                    .toggleWatchedSmart(item, value ?? false);
              },
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: _buildExpandedContent(t),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildExpandedContent(AppLocalizations t) {
    final state = ref.watch(contentProvider);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_result == null) {
      return const SizedBox.shrink();
    }

    if (_result!.notFound) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          t.noSynopsisFound,
          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_result!.posterPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    '${TmdbService.posterBaseUrl}${_result!.posterPath}',
                    width: 70,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _result!.synopsis?.isNotEmpty == true
                      ? _result!.synopsis!
                      : t.noSynopsisAvailable,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        if (_result!.episodes.isNotEmpty)
          EpisodeList(
            contentId: widget.item.id,
            episodes: _result!.episodes,
            watchedEpisodeNumbers:
                state.episodeWatchedNumbers[widget.item.id] ?? const {},
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
