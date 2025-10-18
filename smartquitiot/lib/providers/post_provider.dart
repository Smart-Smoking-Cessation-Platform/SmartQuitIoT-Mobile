import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/post_repository.dart';
import '../viewmodels/post_view_model.dart';
import '../models/state/post_state.dart';
import '../models/post.dart';

/// Repository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

/// ViewModel Provider
final postViewModelProvider = StateNotifierProvider<PostViewModel, PostState>((
  ref,
) {
  final repo = ref.watch(postRepositoryProvider);
  return PostViewModel(repo);
});

/// Individual post providers for specific post IDs
final postDetailProvider = FutureProvider.family<Post, int>((
  ref,
  postId,
) async {
  final postViewModel = ref.watch(postViewModelProvider.notifier);
  await postViewModel.loadPostDetail(postId);
  return ref.watch(postViewModelProvider).selectedPost!;
});

/// Latest posts provider
final latestPostsProvider = FutureProvider<List<Post>>((ref) async {
  final postViewModel = ref.watch(postViewModelProvider.notifier);
  await postViewModel.loadLatestPosts();
  return ref.watch(postViewModelProvider).posts;
});

/// All posts provider with search
final allPostsProvider = FutureProvider.family<List<Post>, String?>((
  ref,
  query,
) async {
  final postViewModel = ref.watch(postViewModelProvider.notifier);
  await postViewModel.loadAllPosts(query: query);
  return ref.watch(postViewModelProvider).posts;
});
