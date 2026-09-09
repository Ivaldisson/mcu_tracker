import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import 'database_helper.dart';
import 'sync_service.dart';

enum SortMode { story, release }

final sortModeProvider = StateProvider<SortMode>((ref) => SortMode.story);

class ContentState {
  final List<ContentItem> items;
  final Set<int> watchedIds;
  final Set<int> skippedIds;
  final Map<int, EpisodeAggregate> episodeAggregates;
  final Map<int, Set<int>> episodeWatchedNumbers;
  final bool isLoading;
  final String? error;

  ContentState({
    required this.items,
    required this.watchedIds,
    required this.skippedIds,
    required this.episodeAggregates,
    required this.episodeWatchedNumbers,
    required this.isLoading,
    this.error,
  });

  ContentState copyWith({
    List<ContentItem>? items,
    Set<int>? watchedIds,
    Set<int>? skippedIds,
    Map<int, EpisodeAggregate>? episodeAggregates,
    Map<int, Set<int>>? episodeWatchedNumbers,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ContentState(
      items: items ?? this.items,
      watchedIds: watchedIds ?? this.watchedIds,
      skippedIds: skippedIds ?? this.skippedIds,
      episodeAggregates: episodeAggregates ?? this.episodeAggregates,
      episodeWatchedNumbers: episodeWatchedNumbers ?? this.episodeWatchedNumbers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<ContentItem> get activeItems =>
      items.where((i) => !skippedIds.contains(i.id)).toList();

  /// Totale minuten van één item: uit de episode-aggregatie als die bestaat,
  /// anders gewoon het bekende runtime_minutes-veld van het item zelf.
  int _totalMinutesFor(ContentItem item) {
    final agg = episodeAggregates[item.id];
    return agg?.totalMinutes ?? item.runtimeMinutes;
  }

  /// Bekeken minuten van één item: precies uit de episode-aggregatie als
  /// die bestaat (dus 3/10 afleveringen telt naar rato), anders de simpele
  /// alles-of-niets seizoen/film-boolean.
  int _watchedMinutesFor(ContentItem item) {
    final agg = episodeAggregates[item.id];
    if (agg != null) return agg.watchedMinutes;
    return watchedIds.contains(item.id) ? item.runtimeMinutes : 0;
  }

  int get totalMinutes =>
      activeItems.fold(0, (sum, i) => sum + _totalMinutesFor(i));

  int get watchedMinutes =>
      activeItems.fold(0, (sum, i) => sum + _watchedMinutesFor(i));

  int get remainingMinutes => totalMinutes - watchedMinutes;

  double get progressFraction =>
      totalMinutes == 0 ? 0 : watchedMinutes / totalMinutes;

  /// Of de seizoen/film-checkbox voor dit item als "aangevinkt" getoond
  /// moet worden. Met episode-tracking: pas waar als ALLE afleveringen
  /// bekeken zijn. Zonder: gewoon de simpele boolean.
  bool isFullyWatched(ContentItem item) {
    final agg = episodeAggregates[item.id];
    if (agg != null) {
      return agg.totalMinutes > 0 && agg.watchedMinutes >= agg.totalMinutes;
    }
    return watchedIds.contains(item.id);
  }
}

class ContentNotifier extends StateNotifier<ContentState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _sync = SyncService();

  ContentNotifier()
      : super(ContentState(
          items: [],
          watchedIds: {},
          skippedIds: {},
          episodeAggregates: {},
          episodeWatchedNumbers: {},
          isLoading: true,
        )) {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await refresh();
  }

  Future<void> _loadFromLocal() async {
    final items = await _db.getAllItems();
    final watched = await _db.getWatchedIds();
    final skipped = await _db.getSkippedIds();
    final aggregates = await _db.getEpisodeAggregates();
    final episodeWatched = await _db.getAllWatchedEpisodeNumbers();
    state = state.copyWith(
      items: items,
      watchedIds: watched,
      skippedIds: skipped,
      episodeAggregates: aggregates,
      episodeWatchedNumbers: episodeWatched,
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      await _sync.sync();
      await _loadFromLocal();
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void dismissError() {
    state = state.copyWith(clearError: true);
  }

  /// Wordt aangeroepen vanuit de seizoen/film-checkbox. Kiest zelf de juiste
  /// weg: bulk alle afleveringen (als bekend) of de simpele boolean.
  Future<void> toggleWatchedSmart(ContentItem item, bool watched) async {
    if (state.episodeAggregates.containsKey(item.id)) {
      await _db.setAllEpisodesWatched(item.id, watched);
    } else {
      await _db.toggleWatched(item.id, watched);
    }
    await _loadFromLocal();
  }

  Future<void> toggleEpisodeWatched(
    int contentId,
    int episodeNumber,
    bool watched,
  ) async {
    await _db.toggleEpisodeWatched(contentId, episodeNumber, watched);
    await _loadFromLocal();
  }

  /// Aangeroepen nadat een tegel is uitgeklapt en TMDB (evt. met
  /// afleveringen) is bevraagd — hoeft verder niks te doen behalve de state
  /// verversen, want het opslaan zelf gebeurt al in TmdbService/DatabaseHelper.
  Future<void> refreshAfterTmdbCache() async {
    await _loadFromLocal();
  }

  Future<void> toggleSkipped(int contentId, bool skipped) async {
    await _db.toggleSkipped(contentId, skipped);
    await _loadFromLocal();
  }

  Future<void> bulkSetSkipped(List<String> importanceLevels, bool skipped) async {
    await _db.bulkSetSkipped(importanceLevels, skipped);
    await _loadFromLocal();
  }
}

final contentProvider =
    StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier();
});
