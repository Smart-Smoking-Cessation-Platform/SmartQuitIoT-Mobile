import '../core/errors/exception.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../repositories/auth_repository.dart';

class NewsRepository {
  final NewsService _newsService;
  final AuthRepository _authRepository;

  NewsRepository({NewsService? newsService, AuthRepository? authRepository})
    : _newsService = newsService ?? NewsService(),
      _authRepository = authRepository ?? AuthRepository();

  /// Get latest news with limit
  Future<List<News>> getLatestNews({int limit = 5}) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw NewsException('Access token not found. Please login again.');
      }

      final response = await _newsService.getLatestNews(
        accessToken: accessToken,
        limit: limit,
      );

      return response.data;
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get latest news: ${e.toString()}');
    }
  }

  /// Get all news with optional search query
  Future<List<News>> getAllNews({String? query}) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw NewsException('Access token not found. Please login again.');
      }

      final response = await _newsService.getAllNews(
        accessToken: accessToken,
        query: query,
      );

      return response.data;
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get news: ${e.toString()}');
    }
  }

  /// Get news detail by ID
  Future<News> getNewsDetail(int newsId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw NewsException('Access token not found. Please login again.');
      }

      final response = await _newsService.getNewsDetail(
        accessToken: accessToken,
        newsId: newsId,
      );

      return response.data;
    } catch (e) {
      if (e is NewsException) {
        rethrow;
      }
      throw NewsException('Failed to get news detail: ${e.toString()}');
    }
  }
}
