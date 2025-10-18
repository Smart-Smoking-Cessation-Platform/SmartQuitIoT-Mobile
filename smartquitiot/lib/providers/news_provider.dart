import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/news_repository.dart';
import '../viewmodels/news_view_model.dart';
import '../models/state/news_state.dart';
import '../models/news.dart';

/// Repository Provider
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

/// ViewModel Provider
final newsViewModelProvider = StateNotifierProvider<NewsViewModel, NewsState>((
  ref,
) {
  final repo = ref.watch(newsRepositoryProvider);
  return NewsViewModel(repo);
});

/// Latest news provider
final latestNewsProvider = FutureProvider<List<News>>((ref) async {
  final newsViewModel = ref.watch(newsViewModelProvider.notifier);
  await newsViewModel.loadLatestNews();
  return ref.watch(newsViewModelProvider).news;
});

/// All news provider
final allNewsProvider = FutureProvider.family<List<News>, String?>((
  ref,
  query,
) async {
  final newsViewModel = ref.watch(newsViewModelProvider.notifier);
  await newsViewModel.loadAllNews(query: query);
  return ref.watch(newsViewModelProvider).news;
});

/// Individual news providers for specific news IDs
final newsDetailProvider = FutureProvider.family<News, int>((
  ref,
  newsId,
) async {
  final newsViewModel = ref.watch(newsViewModelProvider.notifier);
  await newsViewModel.loadNewsDetail(newsId);
  return ref.watch(newsViewModelProvider).selectedNews!;
});
