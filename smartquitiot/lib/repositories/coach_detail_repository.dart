import '../models/coach_detail.dart';
import '../models/slot_available.dart';
import '../services/coach_detail_service.dart';
import '../services/token_storage_service.dart';
import '../core/errors/exception.dart';

class CoachDetailRepository {
  final CoachDetailService _service;
  final TokenStorageService _tokenService = TokenStorageService();

  CoachDetailRepository({CoachDetailService? service})
      : _service = service ?? CoachDetailService();

  /// 🔹 Lấy chi tiết coach (parse từ JSON)
  Future<CoachDetail> getCoachDetail(int coachId) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const CoachException('Missing access token');
      }

      final data = await _service.fetchCoachDetail(token, coachId);
      return CoachDetail.fromJson(data);
    } catch (e, st) {
      print('[ERROR] getCoachDetail failed: $e\n$st');
      throw CoachException('Failed to load coach detail: $e');
    }
  }

  /// 🔹 Lấy danh sách slot khả dụng (parse từ JSON)
  Future<List<SlotAvailable>> getAvailableSlots(int coachId, String date) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const CoachException('Missing access token');
      }

      final dataList = await _service.fetchAvailableSlots(token, coachId, date);

      return dataList
          .map((e) => SlotAvailable.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, st) {
      print('[ERROR] getAvailableSlots failed: $e\n$st');
      throw CoachException('Failed to load available slots: $e');
    }
  }
}
