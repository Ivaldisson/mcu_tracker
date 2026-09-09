import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/content_item.dart';

class EpisodeAggregate {
  final int episodeCount;
  final int watchedMinutes;
  final int totalMinutes;
  EpisodeAggregate(this.episodeCount, this.watchedMinutes, this.totalMinutes);
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mcu_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE content_items (
            id INTEGER PRIMARY KEY,
            updated_at TEXT NOT NULL,
            title TEXT NOT NULL,
            media_type TEXT NOT NULL,
            era TEXT,
            importance TEXT NOT NULL,
            runtime_minutes INTEGER NOT NULL,
            story_date TEXT,
            chronological_order INTEGER,
            release_date TEXT,
            timey_wimey INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE progress (
            content_id INTEGER PRIMARY KEY,
            watched INTEGER NOT NULL DEFAULT 0,
            skipped INTEGER NOT NULL DEFAULT 0
          )
        ''');
        // episodes_json: lijst van {episode_number, name, runtime_minutes,
        // air_date} zoals TMDB die teruggeeft, puur als platte cache -
        // geen aparte genormaliseerde tabel nodig voor statische metadata.
        await db.execute('''
          CREATE TABLE tmdb_cache (
            content_id INTEGER PRIMARY KEY,
            synopsis TEXT,
            poster_path TEXT,
            episodes_json TEXT,
            cached_at TEXT NOT NULL,
            not_found INTEGER NOT NULL DEFAULT 0
          )
        ''');
        // De enige echt nieuwe, persistente tabel: welke afleveringen zijn
        // aangevinkt. Alles over de aflevering zelf (naam/duur) staat al
        // in tmdb_cache.episodes_json hierboven.
        await db.execute('''
          CREATE TABLE episode_progress (
            content_id INTEGER NOT NULL,
            episode_number INTEGER NOT NULL,
            watched INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (content_id, episode_number)
          )
        ''');
      },
    );
  }

  Future<void> upsertItems(List<ContentItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'content_items',
        item.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ContentItem>> getAllItems() async {
    final db = await database;
    final rows = await db.query(
      'content_items',
      orderBy: 'story_date ASC, chronological_order ASC',
    );
    return rows.map((r) => ContentItem.fromDb(r)).toList();
  }

  // --- Watched / skipped (seizoen- of filmniveau) ---

  Future<void> toggleWatched(int contentId, bool watched) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO progress (content_id, watched, skipped)
      VALUES (?, ?, 0)
      ON CONFLICT(content_id) DO UPDATE SET watched = excluded.watched
    ''', [contentId, watched ? 1 : 0]);
  }

  Future<void> toggleSkipped(int contentId, bool skipped) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO progress (content_id, watched, skipped)
      VALUES (?, 0, ?)
      ON CONFLICT(content_id) DO UPDATE SET skipped = excluded.skipped
    ''', [contentId, skipped ? 1 : 0]);
  }

  Future<void> bulkSetSkipped(List<String> importanceLevels, bool skipped) async {
    final db = await database;
    final ids = await db.query(
      'content_items',
      columns: ['id'],
      where: 'importance IN (${importanceLevels.map((_) => '?').join(',')})',
      whereArgs: importanceLevels,
    );
    final batch = db.batch();
    for (final row in ids) {
      final contentId = row['id'] as int;
      batch.rawInsert('''
        INSERT INTO progress (content_id, watched, skipped)
        VALUES (?, 0, ?)
        ON CONFLICT(content_id) DO UPDATE SET skipped = excluded.skipped
      ''', [contentId, skipped ? 1 : 0]);
    }
    await batch.commit(noResult: true);
  }

  Future<Set<int>> getWatchedIds() async {
    final db = await database;
    final rows = await db.query('progress', where: 'watched = 1');
    return rows.map((r) => r['content_id'] as int).toSet();
  }

  Future<Set<int>> getSkippedIds() async {
    final db = await database;
    final rows = await db.query('progress', where: 'skipped = 1');
    return rows.map((r) => r['content_id'] as int).toSet();
  }

  // --- TMDB-cache (synopsis/poster/episodes) ---

  Future<Map<String, dynamic>?> getCachedTmdb(int contentId) async {
    final db = await database;
    final rows = await db.query(
      'tmdb_cache',
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Slaat synopsis/poster/episodes in één keer op. Als er voor het eerst
  /// afleveringen bijkomen (episodes was nog niet bekend) én het seizoen
  /// stond al als 'watched' in het oude, simpele model, migreren we dat
  /// naar "alle afleveringen watched" — zodat de voortgang niet terugspringt
  /// op het moment dat de gebruiker de tegel voor het eerst openklapt.
  Future<void> cacheTmdb(
    int contentId, {
    String? synopsis,
    String? posterPath,
    bool notFound = false,
    List<Map<String, dynamic>>? episodes,
  }) async {
    final db = await database;

    final existing = await getCachedTmdb(contentId);
    final hadEpisodesBefore =
        existing != null && existing['episodes_json'] != null;

    await db.insert(
      'tmdb_cache',
      {
        'content_id': contentId,
        'synopsis': synopsis,
        'poster_path': posterPath,
        'episodes_json': episodes != null ? jsonEncode(episodes) : null,
        'cached_at': DateTime.now().toIso8601String(),
        'not_found': notFound ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (episodes != null && !hadEpisodesBefore) {
      final legacyWatched = await db.query(
        'progress',
        where: 'content_id = ? AND watched = 1',
        whereArgs: [contentId],
      );
      if (legacyWatched.isNotEmpty) {
        await setAllEpisodesWatched(contentId, true, episodes: episodes);
      }
    }
  }

  // --- Episode-voortgang ---

  Future<Set<int>> getWatchedEpisodeNumbers(int contentId) async {
    final db = await database;
    final rows = await db.query(
      'episode_progress',
      columns: ['episode_number'],
      where: 'content_id = ? AND watched = 1',
      whereArgs: [contentId],
    );
    return rows.map((r) => r['episode_number'] as int).toSet();
  }

  Future<void> toggleEpisodeWatched(
    int contentId,
    int episodeNumber,
    bool watched,
  ) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO episode_progress (content_id, episode_number, watched)
      VALUES (?, ?, ?)
      ON CONFLICT(content_id, episode_number) DO UPDATE SET watched = excluded.watched
    ''', [contentId, episodeNumber, watched ? 1 : 0]);
  }

  /// Zet alle afleveringen van een item in één keer aan/uit (de seizoen-
  /// checkbox doet dit zodra er afleveringen bekend zijn). [episodes] mag
  /// meegegeven worden als die toch al in memory zit (bv. net opgehaald),
  /// anders wordt de lijst uit de cache gelezen.
  Future<void> setAllEpisodesWatched(
    int contentId,
    bool watched, {
    List<Map<String, dynamic>>? episodes,
  }) async {
    final db = await database;
    var episodeList = episodes;
    if (episodeList == null) {
      final cached = await getCachedTmdb(contentId);
      final json = cached?['episodes_json'] as String?;
      episodeList = json != null
          ? (jsonDecode(json) as List).cast<Map<String, dynamic>>()
          : [];
    }
    final batch = db.batch();
    for (final ep in episodeList) {
      batch.rawInsert('''
        INSERT INTO episode_progress (content_id, episode_number, watched)
        VALUES (?, ?, ?)
        ON CONFLICT(content_id, episode_number) DO UPDATE SET watched = excluded.watched
      ''', [contentId, ep['episode_number'], watched ? 1 : 0]);
    }
    await batch.commit(noResult: true);
  }

  /// Berekent voor ALLE items met gecachete afleveringen (ongeacht of hun
  /// tegel nu open staat) hoeveel minuten bekeken/totaal zijn, voor de
  /// watchbar. Items zonder gecachete afleveringen komen hier niet in voor
  /// — die blijven gewoon bij de simpele seizoen-boolean uit `progress`.
  /// Alle watched-aflevering-nummers, gegroepeerd per item — voor de
  /// aflevering-checkboxes in de UI (los van de aggregatie-uren hierboven).
  Future<Map<int, Set<int>>> getAllWatchedEpisodeNumbers() async {
    final db = await database;
    final rows = await db.query('episode_progress', where: 'watched = 1');
    final result = <int, Set<int>>{};
    for (final row in rows) {
      final contentId = row['content_id'] as int;
      final episodeNumber = row['episode_number'] as int;
      result.putIfAbsent(contentId, () => {}).add(episodeNumber);
    }
    return result;
  }

  Future<Map<int, EpisodeAggregate>> getEpisodeAggregates() async {
    final db = await database;
    final cacheRows = await db.query(
      'tmdb_cache',
      columns: ['content_id', 'episodes_json'],
      where: 'episodes_json IS NOT NULL',
    );

    final result = <int, EpisodeAggregate>{};
    for (final row in cacheRows) {
      final contentId = row['content_id'] as int;
      final episodes =
          (jsonDecode(row['episodes_json'] as String) as List)
              .cast<Map<String, dynamic>>();
      if (episodes.isEmpty) continue;

      final watchedNumbers = await getWatchedEpisodeNumbers(contentId);
      int totalMinutes = 0;
      int watchedMinutes = 0;
      for (final ep in episodes) {
        final runtime = (ep['runtime_minutes'] as num).toInt();
        totalMinutes += runtime;
        if (watchedNumbers.contains(ep['episode_number'])) {
          watchedMinutes += runtime;
        }
      }
      result[contentId] = EpisodeAggregate(episodes.length, watchedMinutes, totalMinutes);
    }
    return result;
  }
}
