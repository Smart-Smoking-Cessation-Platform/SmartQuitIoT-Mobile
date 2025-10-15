import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MembershipApiService {
  final String _baseUrl = dotenv.env['API_MEMBERSHIP_URL'] ?? 'http://10.0.2.2:8080/api/membership-packages';
  Future<http.Response> getMembershipPackages() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await http.get(uri);
      return response;
    } catch (e) {
      print('Network error fetching packages: $e');
      rethrow;
    }
  }
}
