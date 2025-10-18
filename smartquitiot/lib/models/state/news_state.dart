import '../news.dart';

class NewsState {
  final List<News> news;
  final News? selectedNews;
  final bool isLoading;
  final bool isLoadingDetail;
  final String? error;
  final String? searchQuery;

  const NewsState({
    this.news = const [],
    this.selectedNews,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.error,
    this.searchQuery,
  });

  NewsState copyWith({
    List<News>? news,
    News? selectedNews,
    bool? isLoading,
    bool? isLoadingDetail,
    String? error,
    String? searchQuery,
  }) {
    return NewsState(
      news: news ?? this.news,
      selectedNews: selectedNews ?? this.selectedNews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
