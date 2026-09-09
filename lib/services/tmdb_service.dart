import 'dart:convert';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'api_keys.dart';
import 'database_helper.dart';

class TmdbResult {
  final String? synopsis;
  final String? posterPath;
  final bool notFound;
  // Alleen gevuld voor series met een herkend seizoensnummer.
  final List<Map<String, dynamic>> episodes;

  TmdbResult({
    this.synopsis,
    this.posterPath,
    this.notFound = false,
    this.episodes = const [],
  });
}

class _ParsedTitle {
  final String searchTitle;
  final int? seasonNumber;
  _ParsedTitle(this.searchTitle, this.seasonNumber);
}

_ParsedTitle _parseTitle(String title) {
  final match = RegExp(r'^(.*?)\s*\(Season\s+(\d+)\)\s*$').firstMatch(title);
  if (match != null) {
    return _ParsedTitle(match.group(1)!.trim(), int.parse(match.group(2)!));
  }
  return _ParsedTitle(title, null);
}

String _tmdbLanguageCode() {
  final locale = ui.PlatformDispatcher.instance.locale;
  return locale.languageCode == 'nl' ? 'nl-NL' : 'en-US';
}

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String posterBaseUrl = 'https://image.tmdb.org/t/p/w342';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Authorization': 'Bearer ${ApiKeys.tmdbReadAccessToken}'},
    ),
  );

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// [itemRuntimeMinutes] is de totale seizoensduur zoals we die al kennen
  /// uit onze eigen database — puur als terugvalwaarde om de gemiddelde
  /// aflevering-duur te schatten voor het (zeldzame) geval dat TMDB voor een
  /// specifieke aflevering geen runtime teruggeeft.
  Future<TmdbResult> getSynopsis({
    required int contentId,
    required String title,
    required String mediaType,
    required int itemRuntimeMinutes,
  }) async {
    final cached = await _db.getCachedTmdb(contentId);
    if (cached != null) {
      final episodesJson = cached['episodes_json'] as String?;
      return TmdbResult(
        synopsis: cached['synopsis'] as String?,
        posterPath: cached['poster_path'] as String?,
        notFound: (cached['not_found'] as int) == 1,
        episodes: episodesJson != null
            ? (jsonDecode(episodesJson) as List).cast<Map<String, dynamic>>()
            : const [],
      );
    }

    final isSeries = mediaType == 'series';
    final searchType = isSeries ? 'tv' : 'movie';
    final parsed = _parseTitle(title);
    final language = _tmdbLanguageCode();

    try {
      // TMDB catalogeert eigen series soms onder een "Marvel's "-voorvoegsel
      // (bv. "Marvel's Daredevil"), terwijl een gelijknamige, ongerelateerde
      // show zonder dat voorvoegsel hoger kan scoren op een kale titelmatch
      // (bv. "The Defenders", een rechtbankdrama uit de jaren '60, boven
      // "Marvel's The Defenders"). Voor series proberen we daarom eerst met
      // dat voorvoegsel te zoeken — dat matcht ook prima met shows die het
      // voorvoegsel zelf niet dragen (bv. "WandaVision") — en vallen we pas
      // terug op de kale titel als dat niets oplevert.
      var query =
          isSeries ? "Marvel's ${parsed.searchTitle}" : parsed.searchTitle;
      var response = await _dio.get(
        '/search/$searchType',
        queryParameters: {'query': query, 'language': language},
      );

      var results = response.data['results'] as List;
      if (results.isEmpty && isSeries) {
        response = await _dio.get(
          '/search/$searchType',
          queryParameters: {
            'query': parsed.searchTitle,
            'language': language,
          },
        );
        results = response.data['results'] as List;
      }

      if (results.isEmpty) {
        await _db.cacheTmdb(contentId, notFound: true);
        return TmdbResult(notFound: true);
      }

      final first = results.first;
      String? synopsis = first['overview'] as String?;
      final posterPath = first['poster_path'] as String?;
      List<Map<String, dynamic>> episodes = [];

      if (isSeries) {
        // Titels zonder expliciete "(Season N)"-suffix zijn doorgaans
        // miniseries met precies één seizoen (bv. WandaVision, Secret
        // Invasion) — val in dat geval terug op seizoen 1 in plaats van
        // helemaal geen afleveringen op te halen.
        final seasonNumber = parsed.seasonNumber ?? 1;
        final showId = first['id'];
        try {
          final seasonResponse = await _dio.get(
            '/tv/$showId/season/$seasonNumber',
            queryParameters: {'language': language},
          );
          final seasonOverview = seasonResponse.data['overview'] as String?;
          if (seasonOverview != null && seasonOverview.trim().isNotEmpty) {
            synopsis = seasonOverview;
          }

          final rawEpisodes = seasonResponse.data['episodes'] as List?;
          if (rawEpisodes != null && rawEpisodes.isNotEmpty) {
            // Terugvalwaarde voor ontbrekende per-aflevering runtime.
            final fallbackRuntime =
                (itemRuntimeMinutes / rawEpisodes.length).round();

            episodes = rawEpisodes.map<Map<String, dynamic>>((ep) {
              final runtime = ep['runtime'];
              return {
                'episode_number': ep['episode_number'],
                'name': ep['name'],
                'runtime_minutes':
                    (runtime is int && runtime > 0) ? runtime : fallbackRuntime,
                'air_date': ep['air_date'],
              };
            }).toList();
          }
        } catch (_) {
          // Season-endpoint gefaald: synopsis blijft op show-niveau,
          // geen afleveringenlijst beschikbaar deze keer.
        }
      }

      await _db.cacheTmdb(
        contentId,
        synopsis: synopsis,
        posterPath: posterPath,
        episodes: episodes.isNotEmpty ? episodes : null,
      );
      return TmdbResult(synopsis: synopsis, posterPath: posterPath, episodes: episodes);
    } catch (e) {
      return TmdbResult();
    }
  }
}
