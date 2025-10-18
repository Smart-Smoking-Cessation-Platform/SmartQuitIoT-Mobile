import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/news_state.dart';
import '../repositories/news_repository.dart';

class NewsViewModel extends StateNotifier<NewsState> {
  final NewsRepository _newsRepository;

  NewsViewModel(this._newsRepository) : super(const NewsState());

  /// Load latest news
  Future<void> loadLatestNews({int limit = 5}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final news = await _newsRepository.getLatestNews(limit: limit);
      state = state.copyWith(news: news, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load all news with optional search
  Future<void> loadAllNews({String? query}) async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: query);

    try {
      final news = await _newsRepository.getAllNews(query: query);
      state = state.copyWith(news: news, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load news detail
  Future<void> loadNewsDetail(int newsId) async {
    state = state.copyWith(isLoadingDetail: true, error: null);

    try {
      final news = await _newsRepository.getNewsDetail(newsId);
      state = state.copyWith(
        selectedNews: news,
        isLoadingDetail: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingDetail: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear selected news
  void clearSelectedNews() {
    state = state.copyWith(selectedNews: null);
  }

  /// Refresh news
  Future<void> refreshNews({String? query}) async {
    await loadAllNews(query: query);
  }
}
