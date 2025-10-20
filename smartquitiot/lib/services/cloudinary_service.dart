import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: Replace with your actual Cloudinary credentials
  static const String _cloudName = 'your_cloud_name';
  static const String _apiKey = 'your_api_key';
  static const String _apiSecret = 'your_api_secret';
  static const String _uploadPreset =
      'your_upload_preset'; // For unsigned uploads

  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$_cloudName';

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/image/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'smartquit/posts/images';

      final file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Upload video to Cloudinary
  Future<String> uploadVideo(File videoFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/video/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'smartquit/posts/videos';
      request.fields['resource_type'] = 'video';

      final file = await http.MultipartFile.fromPath(
        'file',
        videoFile.path,
        filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload video: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading video: $e');
    }
  }

  /// Upload image from URL (for external images)
  Future<String> uploadImageFromUrl(String imageUrl) async {
    try {
      final uri = Uri.parse('$_baseUrl/image/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'smartquit/posts/images';
      request.fields['file'] = imageUrl;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image from URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image from URL: $e');
    }
  }

  /// Upload video from URL (for external videos like YouTube)
  Future<String> uploadVideoFromUrl(String videoUrl) async {
    try {
      final uri = Uri.parse('$_baseUrl/video/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'smartquit/posts/videos';
      request.fields['resource_type'] = 'video';
      request.fields['file'] = videoUrl;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload video from URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading video from URL: $e');
    }
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);

      final uri = Uri.parse('$_baseUrl/image/destroy');
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete video from Cloudinary
  Future<bool> deleteVideo(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);

      final uri = Uri.parse('$_baseUrl/video/destroy');
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
          'resource_type': 'video',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate signature for Cloudinary API
  String _generateSignature(String publicId, int timestamp) {
    final stringToSign = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    // In a real implementation, you would use a proper HMAC-SHA1 implementation
    // For now, we'll use a simple hash (you should replace this with proper crypto)
    return stringToSign.hashCode.toString();
  }

  /// Extract public ID from Cloudinary URL
  String? extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3 &&
          pathSegments[0] == 'v1_1' &&
          pathSegments[2] == 'upload') {
        final fileName = pathSegments.last;
        return fileName.split('.').first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
