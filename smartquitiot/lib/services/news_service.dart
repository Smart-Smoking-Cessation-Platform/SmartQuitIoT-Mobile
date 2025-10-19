import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news.dart';
import '../core/errors/exception.dart';
import '../models/news_detail.dart';

class NewsService {
  final String baseUrl;

  NewsService({String? baseUrl})
    : baseUrl = baseUrl ?? dotenv.env['API_NEWS_URL'] ?? '';

  Future<List<News>> getAllNews({String? query, String? accessToken}) async {
    try {
      final uri = query != null && query.isNotEmpty
          ? Uri.parse('$baseUrl?query=$query')
          : Uri.parse(baseUrl);

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((e) => News.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw NewsException('Unauthorized. Token may be expired.');
      } else {
        throw NewsException(
          'Failed to load news. Status code: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      if (e is NewsException) rethrow;
      throw NewsException('Failed to load news: ${e.toString()}');
    }
  }

  Future<List<News>> getLatestNews({
    int limit = 5,
    required String accessToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/latest?limit=$limit');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'] ?? [];
        return data.map((e) => News.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw NewsException('Unauthorized. Token may be expired.');
      } else {
        throw NewsException(
          'Failed to fetch latest news: Status code ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NewsException) rethrow;
      throw NewsException('Failed to fetch latest news: ${e.toString()}');
    }
  }

  Future<NewsDetail> getNewsDetail(int id, {String? accessToken}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return NewsDetail.fromJson(data);
    } else if (response.statusCode == 401) {
      throw NewsException('Unauthorized');
    } else if (response.statusCode == 404) {
      throw NewsException('News not found');
    } else {
      throw NewsException(
        'Failed to load news detail. Status code: ${response.statusCode}',
      );
    }
  }
}
