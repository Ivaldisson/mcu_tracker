import 'package:dio/dio.dart';
import '../models/content_item.dart';
import 'api_keys.dart';

class SyncResult {
  final DateTime serverTime;
  final List<ContentItem> items;
  SyncResult(this.serverTime, this.items);
}

class ApiService {
  // Let op: pas dit aan naar het adres van je mcuapi-LXC.
  static const String baseUrl = 'https://mcuapi.shakycomma.org';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'X-API-Key': ApiKeys.mcuApiKey},
    ),
  );

  Future<SyncResult> fetchContent({DateTime? since}) async {
    final response = await _dio.get(
      '/content',
      queryParameters: since != null ? {'since': since.toIso8601String()} : null,
    );

    final data = response.data;
    final serverTime = DateTime.parse(data['server_time']);
    final items = (data['items'] as List)
        .map((json) => ContentItem.fromJson(json))
        .toList();

    return SyncResult(serverTime, items);
  }
}
