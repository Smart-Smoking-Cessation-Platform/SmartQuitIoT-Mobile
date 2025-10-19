import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/news_detail_state.dart';
import '../repositories/news_repository.dart';
import '../services/news_service.dart';
import '../viewmodels/news_detail_view_model.dart';
import '../viewmodels/news_view_model.dart';
import '../models/state/news_state.dart';
import '../models/news.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final newsViewModelProvider = StateNotifierProvider<NewsViewModel, NewsState>((
  ref,
) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsViewModel(repo);
});

// Service Provider
final newsServiceProvider = Provider((ref) => NewsService(baseUrl: ''));

// Repository Provider
final latestNewsProvider = FutureProvider<List<News>>((ref) async {
  final viewModel = ref.read(newsViewModelProvider.notifier);
  await viewModel.loadLatestNews();
  return ref.read(newsViewModelProvider).news;
});

final newsDetailViewModelProvider =
    StateNotifierProvider<NewsDetailViewModel, NewsDetailState>((ref) {
      final repo = ref.read(newsRepositoryProvider);
      return NewsDetailViewModel(repository: repo);
    });
