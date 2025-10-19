import '../core/errors/exception.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../repositories/auth_repository.dart';

class PostRepository {
  final PostService _postService;
  final AuthRepository _authRepository;

  PostRepository({PostService? postService, AuthRepository? authRepository})
    : _postService = postService ?? PostService(),
      _authRepository = authRepository ?? AuthRepository();

  Future<List<Post>> getLatestPosts({int limit = 5}) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getLatestPosts(
        accessToken: accessToken,
        limit: limit,
      );
      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get latest posts: ${e.toString()}');
    }
  }

  Future<List<Post>> getAllPosts({String? query}) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getAllPosts(
        accessToken: accessToken,
        query: query,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get posts: ${e.toString()}');
    }
  }

  Future<Post> getPostDetail(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getPostDetail(
        accessToken: accessToken,
        postId: postId,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get post detail: ${e.toString()}');
    }
  }

  Future<bool> likePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.likePost(
        accessToken: accessToken,
        postId: postId,
      );

      return response.success;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to like post: ${e.toString()}');
    }
  }

  Future<bool> unlikePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.unlikePost(
        accessToken: accessToken,
        postId: postId,
      );

      return response.success;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to unlike post: ${e.toString()}');
    }
  }

  Future<Post> updatePost(int postId, Map<String, dynamic> updateData) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.updatePost(
        accessToken: accessToken,
        postId: postId,
        updateData: updateData,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to update post: ${e.toString()}');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      await _postService.deletePost(accessToken: accessToken, postId: postId);
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to delete post: ${e.toString()}');
    }
  }

  Future<Post> toggleLikePost(Post post) async {
    try {
      bool success;
      if (post.isLiked == true) {
        success = await unlikePost(post.id);
        if (success) return post.copyWith(likeCount: post.likeCount - 1, isLiked: false);
      } else {
        success = await likePost(post.id);
        if (success) return post.copyWith(likeCount: post.likeCount + 1, isLiked: true);
      }
      return post;
    } catch (e) {
      rethrow;
    }
  }

}
