import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/repositories/diary_record_repository.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';

final diaryRecordRepositoryProvider = Provider<DiaryRecordRepository>((ref) {
  return DiaryRecordRepository();
});

final diaryRecordsProvider = FutureProvider<List<DiaryRecord>>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);
  return repository.getDiaryRecords();
});

final todayDiaryRecordProvider = FutureProvider<DiaryRecord?>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);
  return repository.getTodayDiaryRecord();
});

final diaryRecordNotifierProvider =
    StateNotifierProvider<DiaryRecordNotifier, AsyncValue<void>>((ref) {
      final repository = ref.read(diaryRecordRepositoryProvider);
      return DiaryRecordNotifier(repository);
    });

class DiaryRecordNotifier extends StateNotifier<AsyncValue<void>> {
  final DiaryRecordRepository _repository;

  DiaryRecordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createDiaryRecord(DiaryRecordRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createDiaryRecord(request);
      state = const AsyncValue.data(null);
    } on ServerFailure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> updateDiaryRecord(String id, DiaryRecordRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateDiaryRecord(id, request);
      state = const AsyncValue.data(null);
    } on ServerFailure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> deleteDiaryRecord(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteDiaryRecord(id);
      state = const AsyncValue.data(null);
    } on ServerFailure catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

// Provider để check xem hôm nay đã có diary record chưa
final hasTodayDiaryRecordProvider = FutureProvider<bool>((ref) async {
  final todayRecord = await ref.watch(todayDiaryRecordProvider.future);
  return todayRecord != null;
});
