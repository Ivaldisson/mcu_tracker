import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/content_item.dart';
import '../services/content_provider.dart';
import '../widgets/watch_bar.dart';
import '../widgets/skip_drawer.dart';
import '../widgets/content_tile.dart';
import '../widgets/era_header.dart';
import '../widgets/timeline_header.dart';

// Eén rij in de lijst is óf een sectiekop (era, jaar of maand), óf een
// content-item.
sealed class _ListRow {}

class _EraHeaderRow extends _ListRow {
  final String era;
  _EraHeaderRow(this.era);
}

class _YearHeaderRow extends _ListRow {
  final int year;
  _YearHeaderRow(this.year);
}

class _MonthHeaderRow extends _ListRow {
  final DateTime date;
  _MonthHeaderRow(this.date);
}

class _ItemRow extends _ListRow {
  final ContentItem item;
  _ItemRow(this.item);
}

enum ContentFilter { all, critical, criticalHigh, unwatched, movies, series }

class ContentListScreen extends ConsumerStatefulWidget {
  const ContentListScreen({super.key});

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  ContentFilter _filter = ContentFilter.all;

  List<ContentItem> _applyFilter(ContentState state) {
    var data = state.activeItems;

    switch (_filter) {
      case ContentFilter.critical:
        data = data.where((i) => i.importance == 'critical').toList();
        break;
      case ContentFilter.criticalHigh:
        data = data
            .where((i) => i.importance == 'critical' || i.importance == 'high')
            .toList();
        break;
      case ContentFilter.unwatched:
        data = data.where((i) => !state.watchedIds.contains(i.id)).toList();
        break;
      case ContentFilter.movies:
        data = data.where((i) => i.mediaType == 'movie').toList();
        break;
      case ContentFilter.series:
        data = data
            .where((i) =>
                i.mediaType == 'series' ||
                i.mediaType == 'short' ||
                i.mediaType == 'special')
            .toList();
        break;
      case ContentFilter.all:
        break;
    }
    return data;
  }

  List<ContentItem> _applySort(List<ContentItem> items, SortMode mode) {
    if (mode == SortMode.story) return items; // al zo gesorteerd uit de DB
    final sorted = [...items];
    sorted.sort((a, b) {
      final aDate = a.releaseDate;
      final bDate = b.releaseDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return sorted;
  }

  List<_ListRow> _buildRows(List<ContentItem> items, SortMode mode) {
    if (mode == SortMode.release) {
      // Fasen releasen grotendeels op volgorde, dus era-sectiekoppen kloppen
      // hier juist wel (in tegenstelling tot story-order, waar flashbacks en
      // prequels eras door elkaar laten lopen).
      final rows = <_ListRow>[];
      String? lastEra;
      for (final item in items) {
        final era = item.era;
        if (era != null && era != lastEra) {
          rows.add(_EraHeaderRow(era));
          lastEra = era;
        }
        rows.add(_ItemRow(item));
      }
      return rows;
    }

    // Story-order: jaar-secties met maand-subsecties geven meer timeline-
    // focus dan de brede era/fase-indeling.
    final rows = <_ListRow>[];
    int? lastYear;
    int? lastMonth;
    for (final item in items) {
      final date = item.storyDate;
      if (date != null) {
        if (date.year != lastYear) {
          rows.add(_YearHeaderRow(date.year));
          lastYear = date.year;
          lastMonth = null;
        }
        if (date.month != lastMonth) {
          rows.add(_MonthHeaderRow(date));
          lastMonth = date.month;
        }
      }
      rows.add(_ItemRow(item));
    }
    return rows;
  }

  Widget _filterChip(String label, ContentFilter value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(contentProvider);
    final sortMode = ref.watch(sortModeProvider);
    final visibleItems = _applySort(_applyFilter(state), sortMode);
    final rows = _buildRows(visibleItems, sortMode);

    return Scaffold(
      drawer: const SkipDrawer(),
      appBar: AppBar(
        title: Text(
          t.missionLogTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contentProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            Material(
              color: Colors.red.shade700,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.errorCouldNotRefresh(state.error ?? ''),
                          style:
                              const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () =>
                            ref.read(contentProvider.notifier).dismissError(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          WatchBar(state: state),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(t.filterAll, ContentFilter.all),
                  _filterChip(t.filterCritical, ContentFilter.critical),
                  _filterChip(t.filterCriticalHigh, ContentFilter.criticalHigh),
                  _filterChip(t.filterUnwatched, ContentFilter.unwatched),
                  _filterChip(t.filterMovies, ContentFilter.movies),
                  _filterChip(t.filterSeries, ContentFilter.series),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref.read(contentProvider.notifier).refresh(),
                    child: visibleItems.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    t.noTitlesMatchFilter,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              final row = rows[index];
                              if (row is _EraHeaderRow) {
                                return EraHeader(era: row.era);
                              }
                              if (row is _YearHeaderRow) {
                                return YearHeader(year: row.year);
                              }
                              if (row is _MonthHeaderRow) {
                                return MonthHeader(date: row.date);
                              }
                              final item = (row as _ItemRow).item;
                              return ContentTile(
                                key: ValueKey(item.id),
                                item: item,
                                watched: state.watchedIds.contains(item.id),
                                showReleaseDate: sortMode == SortMode.release,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
