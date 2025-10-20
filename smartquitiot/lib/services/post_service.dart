import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/errors/exception.dart';
import '../models/post_detail.dart';
import '../models/response/error_response.dart';
import '../models/response/post_detail_response.dart';
import '../models/response/post_like_response.dart';
import '../models/response/post_list_response.dart';

class PostService {
  static final String _baseUrl =
      dotenv.env['API_POSTS_URL'] ?? 'http://localhost:8080/api/posts';
  // static const Duration _timeout = Duration(seconds: 30);

  Future<PostListResponse> getLatestPosts({
    required String accessToken,
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get latest posts: ${e.toString()}');
    }
  }

  Future<PostListResponse> getAllPosts({
    required String accessToken,
    String? query,
  }) async {
    try {
      String url = _baseUrl;
      if (query != null && query.isNotEmpty) {
        url += '?query=$query';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get posts: ${e.toString()}');
    }
  }

  Future<PostDetailResponse> getPostDetail({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostDetailResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get post detail: ${e.toString()}');
    }
  }

  Future<PostLikeResponse> likePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostLikeResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to like post: ${e.toString()}');
    }
  }

  Future<PostLikeResponse> unlikePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostLikeResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to unlike post: ${e.toString()}');
    }
  }

  Future<PostDetailResponse> createPost({
    required String accessToken,
    required Map<String, dynamic> postData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostDetailResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to create post: ${e.toString()}');
    }
  }

  Future<PostDetailResponse> updatePost({
    required String accessToken,
    required int postId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateData),
      );
      // .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostDetailResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to update post: ${e.toString()}');
    }
  }

  Future<void> deletePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      // .timeout(_timeout);

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to delete post: ${e.toString()}');
    }
  }
}
