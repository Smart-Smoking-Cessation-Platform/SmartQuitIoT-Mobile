
import '../post.dart';

class PostState {
  final List<Post> posts;
  final Post? selectedPost;
  final bool isLoading;
  final bool isLoadingDetail;
  final String? error;
  final Map<int, bool> likedPosts;

  const PostState({
    this.posts = const [],
    this.selectedPost,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.error,
    this.likedPosts = const {},
  });

  PostState copyWith({
    List<Post>? posts,
    Post? selectedPost,
    bool? isLoading,
    bool? isLoadingDetail,
    String? error,
    Map<int, bool>? likedPosts,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      error: error ?? this.error,
      likedPosts: likedPosts ?? this.likedPosts,
    );
  }

  bool isPostLiked(int postId) {
    return likedPosts[postId] ?? false;
  }
}
