// lib/views/screens/appointments/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// NOTE (VN): File này đã fix:
///  1) Navigator.pop(context, ...) thay cho `Navigator.pop(_, ...)` (undefined `_`)
///  2) Dialog buttons styled (Cancel = outlined pill, Confirm = filled green)
///  3) Avoid layout overflow: coachName/texts use Flexible/ellipsis; right column width reduced and responsive
///  4) After cancel -> call backend cancel endpoint then refresh list (no in-place mutation)
///
/// Comments in English except the NOTE above for you.

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Appointment> _appointments = [];
  bool _isSubmitting = false;
  int? _submittingRatingAppointmentId;

  // map lưu trạng thái đã rate trong session hoặc theo response từ server
  final Map<int, bool> _ratedMap = {};

  // colors
  static const Color primaryGreen = Color(0xFF00D09E);
  static const Color mintBg = Color(0xFFF1FFF3);
  static const Color cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    // Now 3 tabs: Pending (includes cancelled), In Progress, Completed
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Bạn chưa đăng nhập.');
      }

      final service = AppointmentService();
      final raw = await service.getMyAppointments(token);

      // parse raw: detect if backend returned a rating flag/value for each appointment
      _ratedMap.clear();
      for (var e in raw) {
        try {
          final Map<String, dynamic> m = Map<String, dynamic>.from(e);
          int? aid;
          if (m.containsKey('appointmentId')) {
            aid = m['appointmentId'] is int
                ? m['appointmentId'] as int
                : int.tryParse(m['appointmentId'].toString());
          } else if (m.containsKey('id')) {
            aid = m['id'] is int
                ? m['id'] as int
                : int.tryParse(m['id'].toString());
          }
          final ratingKeys = [
            'memberRating',
            'rating',
            'userRating',
            'member_rated',
            'hasRated',
            'rated',
          ];
          bool hasRating = false;
          for (var k in ratingKeys) {
            if (m.containsKey(k) && m[k] != null) {
              final v = m[k];
              if (v is bool && v == true) {
                hasRating = true;
                break;
              } else if (v is num && v > 0) {
                hasRating = true;
                break;
              } else if (v is String && v.isNotEmpty && v != '0') {
                hasRating = true;
                break;
              }
            }
          }
          if (aid != null) {
            _ratedMap[aid] = hasRating;
          }
        } catch (_) {}
      }

      final parsed = raw
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (var a in parsed) {
        if (a.hasRated != null) {
          _ratedMap[a.appointmentId] = a.hasRated!;
        }
      }
      setState(() {
        _appointments = parsed;
        _loading = false;
      });

      // debug
      debugPrint('[Appointments] fetched ${_appointments.length} items');
      for (var a in _appointments) {
        debugPrint(
          '[Appointments] id=${a.appointmentId} status=${a.runtimeStatus} date=${a.date} channel=${a.channelName} rated=${_ratedMap[a.appointmentId] ?? false}',
        );
      }
    } catch (e, st) {
      debugPrint('[ERROR] fetch appointments: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Appointment> _filterByStatus(String status) {
    final want = status.trim().toUpperCase();
    List<String> aliases;
    switch (want) {
      case 'PENDING':
        aliases = ['PENDING'];
        break;
      case 'IN_PROGRESS':
        aliases = ['IN_PROGRESS', 'INPROGRESS', 'IN PROGRESS'];
        break;
      case 'COMPLETED':
        aliases = ['COMPLETED'];
        break;
      case 'CANCELLED':
        aliases = ['CANCELLED', 'CANCELED']; // accept both spellings
        break;
      default:
        aliases = [want];
    }

    return _appointments.where((a) {
      final s = a.runtimeStatus.trim().toUpperCase();
      return aliases.contains(s);
    }).toList();
  }

  // check if current instant is inside join window
  bool _isWithinJoinWindow(Appointment a) {
    try {
      final start = a.joinWindowStart;
      final end = a.joinWindowEnd;
      if (start == null || end == null) return false;

      // ensure comparing in UTC
      final startUtc = start.toUtc();
      final endUtc = end.toUtc();
      final nowUtc = DateTime.now().toUtc();

      final ok = !nowUtc.isBefore(startUtc) && !nowUtc.isAfter(endUtc);
      debugPrint(
        '[JoinWindow] appointment=${a.appointmentId} start=$startUtc end=$endUtc now=$nowUtc ok=$ok',
      );
      return ok;
    } catch (e, st) {
      debugPrint(
        '[JoinWindow] parse error for appointment ${a.appointmentId}: $e\n$st',
      );
      return false;
    }
  }

  Future<void> _onJoinPressed(Appointment a) async {
    debugPrint('[Join] pressed for appointment ${a.appointmentId}');
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập hoặc token hết hạn')),
      );
      return;
    }

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Preparing meeting...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final svc = AppointmentService();
      final resp = await svc.requestJoinToken(a.appointmentId, token);
      debugPrint('[JoinToken] resp = $resp');

      Navigator.pop(context); // remove loading

      context.pushNamed(
        'meeting',
        extra: {
          'channel': resp['channel'],
          'token': resp['token'],
          'uid': resp['uid'],
          'appointmentId': a.appointmentId,
          'expiresAt': resp['expiresAt'],
        },
      );
    } catch (e, st) {
      debugPrint('[Join] requestJoinToken failed: $e\n$st');
      Navigator.pop(context); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy token vào phòng: $e')),
      );
    }
  }

  // method riêng trong class _AppointmentsScreenState
  Future<Map<String, dynamic>?> _showRatingDialog() {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int selectedStars = 5;
        String comment = '';
        return StatefulBuilder(
          builder: (ctx2, setSt) {
            return DraggableScrollableSheet(
              initialChildSize: 0.46,
              minChildSize: 0.32,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, controller) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const Text(
                          'Rate your session',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please share your feedback about the coaching session so the coach can improve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 18),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final idx = i + 1;
                                final bool active = idx <= selectedStars;
                                return GestureDetector(
                                  onTap: () => setSt(() => selectedStars = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    transform: Matrix4.identity()
                                      ..scale(active ? 1.14 : 1.0),
                                    child: Icon(
                                      active
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: active ? 36 : 32,
                                      color: active
                                          ? Colors.amber
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            // label
                            Builder(
                              builder: (_) {
                                final labels = [
                                  'Terrible',
                                  'Bad',
                                  'Okay',
                                  'Good',
                                  'Excellent',
                                ];
                                return Text(
                                  labels[selectedStars - 1],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          maxLines: 4,
                          onChanged: (v) => comment = v,
                          decoration: InputDecoration(
                            hintText: 'Write comment (optional)...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx2).pop(null),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(ctx2).pop({
                                  'stars': selectedStars,
                                  'comment': comment.trim(),
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D09E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Rate flow: open dialog, choose stars + optional comment, POST to backend and lock button
  Future<void> _onRatePressed(Appointment a) async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập.')));
      return;
    }

    final result = await _showRatingDialog();
    if (result == null) return; // user cancelled

    final int selectedStars = result['stars'] is int
        ? result['stars'] as int
        : int.tryParse(result['stars']?.toString() ?? '') ?? 5;
    final String comment = result['comment'] != null
        ? result['comment'].toString().trim()
        : '';

    // prevent double submit across taps
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submittingRatingAppointmentId = a.appointmentId;
    });

    // show global loading
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Submitting rating...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final svc = AppointmentService();
      await svc.rateAppointment(a.appointmentId, selectedStars, comment, token);

      // optimistic local update: mark rated immediately
      setState(() {
        _ratedMap[a.appointmentId] = true;
      });

      // refresh canonical state from server (optional), but preserve local rated flag
      await _fetchAppointments();
      setState(() {
        _ratedMap[a.appointmentId] =
            true; // re-apply in case server response didn't include it
      });

      Navigator.pop(context); // remove loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thank your feedback!')));
    } catch (e, st) {
      try {
        Navigator.pop(context);
      } catch (_) {}
      debugPrint('[Rate] failed: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Can not send feedback: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
        _submittingRatingAppointmentId = null;
      });
    }
  }

  // ----- Cancel flow (member) -----
  Future<void> _onCancelPressed(Appointment a) async {
    // Show confirm dialog with custom styles. Use context properly (no `_` variable).
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm Cancel'),
          content: const Text(
            'Are you sure you want to cancel this appointment? (If you cancel, your turn will NOT be refunded)',
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            // Cancel (outlined pill)
            SizedBox(
              height: 44,
              width: 120,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(color: Color(0xFF00D09E)),
                  foregroundColor: const Color(0xFF00D09E),
                ),
                child: const Text('No'),
              ),
            ),
            const SizedBox(width: 8),
            // Confirm (filled primary)
            SizedBox(
              height: 44,
              width: 120,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // call cancel API
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập.')));
      return;
    }

    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Cancelling appointment...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    try {
      final svc = AppointmentService();
      // NOTE: AppointmentService must implement cancelAppointment(appointmentId, token)
      await svc.cancelAppointment(a.appointmentId, token);

      Navigator.pop(context); // remove loading

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hủy lịch thành công')));

      // refresh list from server (safer than local mutation)
      await _fetchAppointments();
    } catch (e, st) {
      try {
        Navigator.pop(context);
      } catch (_) {}
      debugPrint('[Cancel] failed: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể hủy lịch: $e')));
    }
  }

  Widget _buildList(List<Appointment> list) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading appointments...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _fetchAppointments,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No appointments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'You don\'t have any appointments in this category yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _fetchAppointments,
          child: SizedBox(
            height: constraints.maxHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final a = list[i];
                DateTime? dateParsed;
                try {
                  dateParsed = DateFormat('yyyy-MM-dd').parse(a.date);
                } catch (_) {}
                final dateLabel = dateParsed != null
                    ? DateFormat('EEE, dd MMM yyyy').format(dateParsed)
                    : a.date;
                final start = a.startTime.length >= 5
                    ? a.startTime.substring(0, 5)
                    : a.startTime;
                final end = a.endTime.length >= 5
                    ? a.endTime.substring(0, 5)
                    : a.endTime;
                final timeLabel = '$start • $end';

                final initials = _initialsFromName(a.coachName);

                final canJoin = _isWithinJoinWindow(a);

                final isCancelled = a.runtimeStatus.toUpperCase().contains(
                  'CANCEL',
                );

                // determine if this appointment is in Completed state
                final isCompleted =
                    a.runtimeStatus.toUpperCase() == 'COMPLETED';

                // prefer server-provided flag if available, else fall back to client-side _ratedMap
                final hasRated = (a.hasRated != null)
                    ? a.hasRated!
                    : (_ratedMap[a.appointmentId] ?? false);
                final bool isSubmittingThis =
                    _isSubmitting &&
                    _submittingRatingAppointmentId == a.appointmentId;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCancelled
                          ? Colors.grey.shade200
                          : primaryGreen.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCancelled
                            ? Colors.black.withOpacity(0.03)
                            : primaryGreen.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showAppointmentDetail(
                        context,
                        a,
                        dateLabel,
                        timeLabel,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // avatar + ghost on cancelled
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isCancelled
                                    ? null
                                    : LinearGradient(
                                        colors: [
                                          primaryGreen.withOpacity(0.15),
                                          primaryGreen.withOpacity(0.25),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: isCancelled
                                    ? Colors.grey.shade100
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: isCancelled
                                        ? Colors.transparent
                                        : primaryGreen.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: isCancelled
                                        ? Colors.grey.shade600
                                        : primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // content column: make it flexible to avoid overflow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // coach name: allow ellipsis
                                  Text(
                                    a.coachName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: isCancelled
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color: isCancelled
                                            ? Colors.grey.shade400
                                            : primaryGreen.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dateLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey.shade500
                                                : Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: isCancelled
                                            ? Colors.grey.shade400
                                            : primaryGreen.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          timeLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey.shade500
                                                : Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCancelled
                                              ? Colors.grey.shade100
                                              : primaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Slot ${a.slotId}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey.shade600
                                                : primaryGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'ID: ${a.appointmentId}',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // right column: responsive controls
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 100,
                                maxWidth: 140,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _statusChip(a.runtimeStatus),
                                  const SizedBox(height: 12),
                                  // Completed => show Rate button (if not rated) OR disabled "Rated"
                                  if (isCompleted && !isCancelled) ...[
                                    hasRated
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 16,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Rated',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : isSubmittingThis
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryGreen,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryGreen
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Submitting',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () => _onRatePressed(a),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreen,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 2,
                                              shadowColor: primaryGreen
                                                  .withOpacity(0.3),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Rate',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ]
                                  // Join button only if not cancelled, status IN_PROGRESS and within window
                                  else if (!isCancelled &&
                                      a.runtimeStatus.toUpperCase().contains(
                                        'IN_PROGRESS',
                                      ) &&
                                      canJoin)
                                    ElevatedButton.icon(
                                      onPressed: () => _onJoinPressed(a),
                                      icon: const Icon(
                                        Icons.video_call_rounded,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Join',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 2,
                                        shadowColor: primaryGreen.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    )
                                  else
                                    IconButton(
                                      onPressed: () => _showAppointmentDetail(
                                        context,
                                        a,
                                        dateLabel,
                                        timeLabel,
                                      ),
                                      icon: Icon(
                                        Icons.chevron_right_rounded,
                                        color: isCancelled
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _statusChip(String? status) {
    final s = (status ?? '').toUpperCase();
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;
    switch (s) {
      case 'PENDING':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.pending_rounded;
        text = 'Pending';
        break;
      case 'IN_PROGRESS':
      case 'INPROGRESS':
      case 'IN PROGRESS':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.play_circle_outline_rounded;
        text = 'In progress';
        break;
      case 'COMPLETED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline_rounded;
        text = 'Completed';
        break;
      case 'CANCELLED':
      case 'CANCELED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        text = 'Cancelled';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline_rounded;
        text = s.isEmpty ? 'Unknown' : s;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    try {
      return DateFormat('HH:mm • dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      return dt.toString();
    }
  }

  String _prettyCancelledBy(String? cancelledBy) {
    if (cancelledBy == null) return 'Unknown';
    final s = cancelledBy.toUpperCase();
    if (s.contains('COACH')) return 'Coach';
    if (s.contains('MEMBER')) return 'Member';
    // fallback: return value
    return cancelledBy;
  }

  void _showAppointmentDetail(
    BuildContext context,
    Appointment a,
    String dateLabel,
    String timeLabel,
  ) {
    final isCancelled = a.runtimeStatus.toUpperCase().contains('CANCEL');
    final isCompleted = a.runtimeStatus.toUpperCase() == 'COMPLETED';
    final initials = _initialsFromName(a.coachName);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${a.appointmentId}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Coach Section với Avatar
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Coach Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: mintBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryGreen.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGreen.withOpacity(0.2),
                                    primaryGreen.withOpacity(0.3),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coach',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.coachName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status Chip
                      Center(child: _statusChip(a.runtimeStatus)),

                      const SizedBox(height: 24),

                      // Divider
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),

                      const SizedBox(height: 24),

                      // Details Section
                      _buildEnhancedDetailRow(
                        Icons.calendar_today_rounded,
                        'Date',
                        dateLabel,
                        Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      _buildEnhancedDetailRow(
                        Icons.access_time_rounded,
                        'Time',
                        timeLabel,
                        Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      _buildEnhancedDetailRow(
                        Icons.confirmation_number_rounded,
                        'Slot',
                        'Slot ${a.slotId}',
                        Colors.purple,
                      ),

                      // Join window chỉ hiển thị khi không cancelled và không completed
                      if (!isCancelled && !isCompleted) ...[
                        const SizedBox(height: 20),
                        _buildEnhancedDetailRow(
                          Icons.video_call_rounded,
                          'Join Window',
                          '${_fmtDt(a.joinWindowStart)} → ${_fmtDt(a.joinWindowEnd)}',
                          Colors.teal,
                        ),
                      ],

                      // Cancelled Section
                      if (isCancelled) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 20,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cancelled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildEnhancedDetailRow(
                                Icons.person_outline_rounded,
                                'Cancelled by',
                                _prettyCancelledBy(a.cancelledBy),
                                Colors.red,
                                small: true,
                              ),
                              const SizedBox(height: 12),
                              _buildEnhancedDetailRow(
                                Icons.schedule_rounded,
                                'Cancelled at',
                                _fmtDt(a.cancelledAt),
                                Colors.red,
                                small: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Cancel button cho PENDING status
                      if (!isCancelled &&
                          a.runtimeStatus.toUpperCase().contains(
                            'PENDING',
                          )) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _onCancelPressed(a);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.red.shade300,
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel_outlined, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Cancel Appointment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: primaryGreen.withOpacity(0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor, {
    bool small = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: small ? 18 : 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: small ? 10 : 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: small ? 14 : 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingOnly = _filterByStatus('PENDING');
    final cancelled = _filterByStatus('CANCELLED');
    final pendingTabList = [
      ...pendingOnly,
      ...cancelled,
    ]; // Pending tab = pending + cancelled
    final inprogress =
        _filterByStatus('IN_PROGRESS') + _filterByStatus('INPROGRESS');
    final completed = _filterByStatus('COMPLETED');

    return Scaffold(
      // prevent keyboard from resizing the body which can lead to layout errors
      resizeToAvoidBottomInset: false,
      backgroundColor: mintBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          backgroundColor: primaryGreen,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, Color(0xFF00B88D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'My Appointments',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: primaryGreen,
                  unselectedLabelColor: Colors.white.withOpacity(0.9),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                      child: Center(
                        child: Text('Pending (${pendingTabList.length})'),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text('In Progress (${inprogress.length})'),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text('Completed (${completed.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pendingTabList),
          _buildList(inprogress),
          _buildList(completed),
        ],
      ),
    );
  }
}
