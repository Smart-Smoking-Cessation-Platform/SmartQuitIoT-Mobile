import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../models/state/post_state.dart';
import '../repositories/post_repository.dart';

class PostViewModel extends StateNotifier<PostState> {
  final PostRepository _postRepository;

  PostViewModel(this._postRepository) : super(const PostState());

  /// Load latest posts
  Future<void> loadLatestPosts({int limit = 5}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _postRepository.getLatestPosts(limit: limit);
      state = state.copyWith(posts: posts, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load all posts with optional search
  Future<void> loadAllPosts({String? query}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _postRepository.getAllPosts(query: query);
      state = state.copyWith(posts: posts, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load post detail
  Future<void> loadPostDetail(int postId) async {
    state = state.copyWith(isLoadingDetail: true, error: null);

    try {
      final post = await _postRepository.getPostDetail(postId);
      state = state.copyWith(
        selectedPost: post,
        isLoadingDetail: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingDetail: false, error: e.toString());
    }
  }

  /// Toggle like for a post
  Future<void> toggleLike(int postId) async {
    try {
      final isCurrentlyLiked = state.isPostLiked(postId);
      bool success;

      if (isCurrentlyLiked) {
        success = await _postRepository.unlikePost(postId);
      } else {
        success = await _postRepository.likePost(postId);
      }

      if (success) {
        // Update the liked posts map
        final updatedLikedPosts = Map<int, bool>.from(state.likedPosts);
        updatedLikedPosts[postId] = !isCurrentlyLiked;

        // Update the post in the list if it exists
        final updatedPosts = <Post>[];
        for (final post in state.posts) {
          if (post.id == postId) {
            updatedPosts.add(
              post.copyWith(
                likeCount: isCurrentlyLiked
                    ? post.likeCount - 1
                    : post.likeCount + 1,
                isLiked: !isCurrentlyLiked,
              ),
            );
          } else {
            updatedPosts.add(post);
          }
        }

        // Update selected post if it's the same post
        Post? updatedSelectedPost = state.selectedPost;
        if (state.selectedPost != null && state.selectedPost!.id == postId) {
          updatedSelectedPost = state.selectedPost!.copyWith(
            likeCount: isCurrentlyLiked
                ? state.selectedPost!.likeCount - 1
                : state.selectedPost!.likeCount + 1,
            isLiked: !isCurrentlyLiked,
          );
        }

        state = state.copyWith(
          posts: updatedPosts,
          selectedPost: updatedSelectedPost,
          likedPosts: updatedLikedPosts,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update a post
  Future<void> updatePost(int postId, Map<String, dynamic> updateData) async {
    try {
      final updatedPost = await _postRepository.updatePost(postId, updateData);

      // Update the post in the list
      final updatedPosts = <Post>[];
      for (final post in state.posts) {
        if (post.id == postId) {
          updatedPosts.add(updatedPost);
        } else {
          updatedPosts.add(post);
        }
      }

      // Update selected post if it's the same post
      Post? updatedSelectedPost = state.selectedPost;
      if (state.selectedPost != null && state.selectedPost!.id == postId) {
        updatedSelectedPost = updatedPost;
      }

      state = state.copyWith(
        posts: updatedPosts,
        selectedPost: updatedSelectedPost,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    try {
      await _postRepository.deletePost(postId);

      // Remove the post from the list
      final updatedPosts = <Post>[];
      for (final post in state.posts) {
        if (post.id != postId) {
          updatedPosts.add(post);
        }
      }

      // Clear selected post if it's the deleted post
      Post? updatedSelectedPost = state.selectedPost;
      if (state.selectedPost != null && state.selectedPost!.id == postId) {
        updatedSelectedPost = null;
      }

      // Remove from liked posts map
      final updatedLikedPosts = Map<int, bool>.from(state.likedPosts);
      updatedLikedPosts.remove(postId);

      state = state.copyWith(
        posts: updatedPosts,
        selectedPost: updatedSelectedPost,
        likedPosts: updatedLikedPosts,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear selected post
  void clearSelectedPost() {
    state = state.copyWith(selectedPost: null);
  }

  /// Refresh posts
  Future<void> refreshPosts({int limit = 5}) async {
    await loadLatestPosts(limit: limit);
  }
}
