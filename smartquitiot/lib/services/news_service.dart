import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/errors/exception.dart';
import '../models/news.dart';
import '../models/response/error_response.dart';

class NewsService {
  static final String _baseUrl =
      dotenv.env['API_NEWS_URL'] ?? 'http://localhost:8080/api/news';
  static const Duration _timeout = Duration(seconds: 30);

  /// Get latest news with limit
  Future<NewsListResponse> getLatestNews({
    required String accessToken,
    int limit = 5,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/latest?limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return NewsListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw NewsException(errorResponse.message);
      }
    } on http.ClientException {
      throw NewsException('Network error. Please check your connection.');
    } on FormatException {
      throw NewsException('Invalid response format from server.');
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get latest news: ${e.toString()}');
    }
  }

  /// Get all news with optional search query
  Future<NewsListResponse> getAllNews({
    required String accessToken,
    String? query,
  }) async {
    try {
      String url = _baseUrl;
      if (query != null && query.isNotEmpty) {
        url += '?query=$query';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return NewsListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw NewsException(errorResponse.message);
      }
    } on http.ClientException {
      throw NewsException('Network error. Please check your connection.');
    } on FormatException {
      throw NewsException('Invalid response format from server.');
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get news: ${e.toString()}');
    }
  }

  /// Get news detail by ID
  Future<NewsDetailResponse> getNewsDetail({
    required String accessToken,
    required int newsId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/$newsId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return NewsDetailResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw NewsException(errorResponse.message);
      }
    } on http.ClientException {
      throw NewsException('Network error. Please check your connection.');
    } on FormatException {
      throw NewsException('Invalid response format from server.');
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get news detail: ${e.toString()}');
    }
  }
}
