import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/views/screens/diary/create_diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';

class DiaryRecordCard extends ConsumerWidget {
  const DiaryRecordCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryTodayViewModelProvider);
    final diaryNotifier = ref.read(diaryTodayViewModelProvider.notifier);

    final bool hasRecordToday = diaryState.hasRecordToday ?? false;
    final bool isBusy = diaryState.isLoading || diaryState.isRefreshing;
    final Color accentColor = hasRecordToday
        ? const Color(0xFF2563EB)
        : const Color(0xFF00D09E);
    final Color badgeColor = hasRecordToday
        ? const Color(0xFF2563EB).withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasRecordToday ? const Color(0xFFF2F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasRecordToday
              ? const Color(0xFF2563EB).withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: hasRecordToday
                ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: accentColor.withValues(alpha: 0.08),
          onTap: () => hasRecordToday
              ? _openDiaryScreen(context)
              : _openCreateDiaryScreen(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        hasRecordToday
                            ? Icons.celebration_outlined
                            : Icons.book_outlined,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasRecordToday
                                ? 'You checked in today 🎉'
                                : 'Diary Record',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2933),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              hasRecordToday
                                  ? 'Great job! Come back tomorrow for another check-in.'
                                  : 'Start a quick entry to track your progress today.',
                              key: ValueKey(hasRecordToday),
                              style: TextStyle(
                                fontSize: 14,
                                color: hasRecordToday
                                    ? const Color(0xFF475467)
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isBusy)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          Text(
                            isBusy
                                ? 'Checking...'
                                : hasRecordToday
                                ? 'Completed'
                                : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      splashRadius: 18,
                      onPressed: isBusy
                          ? null
                          : diaryNotifier.refreshTodayStatus,
                      icon: Icon(
                        Icons.refresh_outlined,
                        size: 20,
                        color: isBusy
                            ? Colors.grey[400]
                            : accentColor.withValues(alpha: 0.9),
                      ),
                      tooltip: 'Refresh status',
                    ),
                  ],
                ),
                if (diaryState.error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(
                    message: diaryState.error!,
                    accentColor: accentColor,
                    onRetry: diaryNotifier.refreshTodayStatus,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        hasRecordToday ? 'View Diary' : 'View Diary',
                        Icons.visibility_outlined,
                        () => _openDiaryScreen(context),
                        accentColor: accentColor,
                        isPrimary: hasRecordToday,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        hasRecordToday ? 'Come back tomorrow' : 'Add Entry',
                        hasRecordToday
                            ? Icons.watch_later_outlined
                            : Icons.add_circle_outline,
                        () => _openCreateDiaryScreen(context),
                        accentColor: accentColor,
                        isPrimary: !hasRecordToday,
                        isDisabled: hasRecordToday,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDiaryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiaryScreen()),
    );
  }

  void _openCreateDiaryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDiaryScreen()),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap, {
    required Color accentColor,
    bool isPrimary = false,
    bool isDisabled = false,
  }) {
    final Color backgroundColor;
    final Color foregroundColor;
    if (isDisabled) {
      backgroundColor = Colors.grey[200]!;
      foregroundColor = Colors.grey[500]!;
    } else if (isPrimary) {
      backgroundColor = accentColor;
      foregroundColor = Colors.white;
    } else {
      backgroundColor = accentColor.withValues(alpha: 0.08);
      foregroundColor = accentColor;
    }

    return Opacity(
      opacity: isDisabled ? 0.9 : 1,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: isPrimary || isDisabled
                ? null
                : Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final Color accentColor;
  final VoidCallback onRetry;

  const _ErrorBanner({
    required this.message,
    required this.accentColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
