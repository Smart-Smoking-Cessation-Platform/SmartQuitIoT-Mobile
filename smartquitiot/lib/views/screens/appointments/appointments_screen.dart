// lib/views/screens/appointments/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

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

      final parsed = raw
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      setState(() {
        _appointments = parsed;
        _loading = false;
      });

      // debug
      debugPrint('[Appointments] fetched ${_appointments.length} items');
      for (var a in _appointments) {
        debugPrint(
          '[Appointments] id=${a.appointmentId} status=${a.runtimeStatus} date=${a.date} channel=${a.channelName} joinWindowStart=${a.joinWindowStart} joinWindowEnd=${a.joinWindowEnd}',
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
      final s = (a.runtimeStatus ?? '').trim().toUpperCase();
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
      debugPrint('[JoinWindow] appointment=${a.appointmentId} start=$startUtc end=$endUtc now=$nowUtc ok=$ok');
      return ok;
    } catch (e, st) {
      debugPrint('[JoinWindow] parse error for appointment ${a.appointmentId}: $e\n$st');
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
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final svc = AppointmentService();
      final resp = await svc.requestJoinToken(a.appointmentId, token);
      debugPrint('[JoinToken] resp = $resp');

      Navigator.pop(context); // remove loading

      context.pushNamed('meeting', extra: {
        'channel': resp['channel'],
        'token': resp['token'],
        'uid': resp['uid'],
        'appointmentId': a.appointmentId,
        'expiresAt': resp['expiresAt'],
      });
    } catch (e, st) {
      debugPrint('[Join] requestJoinToken failed: $e\n$st');
      Navigator.pop(context); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy token vào phòng: $e')),
      );
    }
  }

  Widget _buildList(List<Appointment> list) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Center(child: Text('No appointments')),
            SizedBox(height: 60),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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

                final isCancelled = (a.runtimeStatus ?? '').toUpperCase().contains('CANCEL');

                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showAppointmentDetail(
                        context,
                        a,
                        dateLabel,
                        timeLabel,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            // avatar + ghost on cancelled
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: isCancelled ? Colors.grey.shade200 : mintBg,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: isCancelled ? Colors.grey.shade600 : primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.coachName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCancelled ? Colors.grey.shade600 : Colors.black87,
                                      decoration: isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          dateLabel,
                                          style: TextStyle(
                                            color: isCancelled ? Colors.grey : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        timeLabel,
                                        style: TextStyle(
                                          color: isCancelled ? Colors.grey : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Slot ${a.slotId}',
                                        style: TextStyle(
                                          color: isCancelled ? Colors.grey.shade500 : Colors.black45,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Appointment ID: ${a.appointmentId}',
                                    style: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // show cancelled detail if cancelled (small red text)
                                  if (isCancelled) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _cancelledLine(a),
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // right column: fixed width so all items align
                            SizedBox(
                              width: 110,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // status chip (always shown) - CANCELLED now red
                                  SizedBox(
                                    height: 36,
                                    child: Center(child: _statusChip(a.runtimeStatus)),
                                  ),
                                  const SizedBox(height: 8),
                                  // Join button only if not cancelled, status IN_PROGRESS and within window
                                  if (!isCancelled &&
                                      a.runtimeStatus != null &&
                                      a.runtimeStatus!.toUpperCase().contains('IN_PROGRESS') &&
                                      canJoin)
                                    ElevatedButton.icon(
                                      onPressed: () => _onJoinPressed(a),
                                      icon: const Icon(Icons.video_call, size: 16),
                                      label: const Text('Join'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        minimumSize: const Size(80, 36),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
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
                                        Icons.chevron_right,
                                        color: isCancelled ? Colors.grey.shade400 : Colors.grey,
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
    Color color;
    String text;
    switch (s) {
      case 'PENDING':
        color = Colors.orange.shade700;
        text = 'Pending';
        break;
      case 'IN_PROGRESS':
      case 'INPROGRESS':
      case 'IN PROGRESS':
        color = Colors.blue.shade700;
        text = 'In progress';
        break;
      case 'COMPLETED':
        color = Colors.green.shade600;
        text = 'Completed';
        break;
      case 'CANCELLED':
      case 'CANCELED':
      // changed: CANCELLED -> red chip
        color = Colors.red.shade600;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = s.isEmpty ? 'Unknown' : s;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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

  String _cancelledLine(Appointment a) {
    // show nice line: "Cancelled by Coach • 16:39 • 30 Oct 2025"
    final who = _prettyCancelledBy(a.cancelledBy);
    final at = a.cancelledAt;
    final when = at != null ? DateFormat('HH:mm • dd MMM yyyy').format(at.toLocal()) : '-';
    return 'Cancelled by $who • $when';
  }

  void _showAppointmentDetail(
      BuildContext context,
      Appointment a,
      String dateLabel,
      String timeLabel,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Appointment ${a.appointmentId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coach: ${a.coachName}'),
            const SizedBox(height: 8),
            Text('Date: $dateLabel'),
            const SizedBox(height: 8),
            Text('Time: $timeLabel'),
            const SizedBox(height: 8),
            Text('Slot: ${a.slotId}'),
            const SizedBox(height: 8),
            Text('Status: ${a.runtimeStatus}'),
            const SizedBox(height: 8),
            Text('Join window: ${_fmtDt(a.joinWindowStart)} → ${_fmtDt(a.joinWindowEnd)}'),
            if ((a.runtimeStatus ?? '').toUpperCase().contains('CANCEL')) ...[
              const SizedBox(height: 8),
              Text('Cancelled by: ${_prettyCancelledBy(a.cancelledBy)}'),
              const SizedBox(height: 6),
              Text('Cancelled at: ${_fmtDt(a.cancelledAt)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
    final pendingTabList = [...pendingOnly, ...cancelled]; // Pending tab = pending + cancelled
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
                      child: Center(child: Text('Pending (${pendingTabList.length})')),
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
